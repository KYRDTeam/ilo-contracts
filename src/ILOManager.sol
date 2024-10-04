// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.7.6;
pragma abicoder v2;

import { IILOManager } from './interfaces/IILOManager.sol';
import { IILOPoolBase } from './interfaces/IILOPoolBase.sol';
import { IILOPool } from './interfaces/IILOPool.sol';
import { IILOPoolSale } from './interfaces/IILOPoolSale.sol';
import { Initializable } from './base/Initializable.sol';
import { ITokenFactory } from './interfaces/ITokenFactory.sol';
import { IERC20 } from './interfaces/external/IERC20.sol';

import { ChainId } from '@uniswap/v3-periphery/contracts/libraries/ChainId.sol';
import { TransferHelper } from '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import { PoolAddress } from '@uniswap/v3-periphery/contracts/libraries/PoolAddress.sol';
import { IUniswapV3Factory } from '@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol';
import { IUniswapV3Pool } from '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';
import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import { Clones } from '@openzeppelin/contracts/proxy/Clones.sol';
import { EnumerableSet } from '@openzeppelin/contracts/utils/EnumerableSet.sol';
import { TickMath } from '@uniswap/v3-core/contracts/libraries/TickMath.sol';
import "hardhat/console.sol"

contract ILOManager is IILOManager, Ownable, Initializable {
    address public override UNIV3_FACTORY;
    address public override TOKEN_FACTORY;

    uint16 public override PLATFORM_FEE;
    uint16 public override PERFORMANCE_FEE;
    address public override FEE_TAKER;
    address public override ILO_POOL_IMPLEMENTATION;
    address public override ILO_POOL_SALE_IMPLEMENTATION;
    uint256 public override INIT_PROJECT_FEE;

    mapping(string => Project) private _projects; // map projectId => project)
    mapping(string => EnumerableSet.AddressSet) private _initializedILOPools; // map projectId => list of initialized ilo pools

    modifier onlyProjectAdmin(string calldata projectId) {
        require(_projects[projectId].admin == msg.sender, 'UA');
        _;
    }

    modifier onlyInitializedPool(string calldata projectId) {
        require(
            EnumerableSet.contains(_initializedILOPools[projectId], msg.sender),
            'NP'
        );
        _;
    }

    modifier onlyInitializedProject(string calldata projectId) {
        require(_projects[projectId].status == ProjectStatus.INITIALIZED, 'NA');
        _;
    }

    modifier ownerOrProjectAdmin(string calldata projectId) {
        require(
            msg.sender == owner() || _projects[projectId].admin == msg.sender,
            'UA'
        );
        _;
    }

    /// @dev since deploy via deployer so we need to claim ownership
    constructor() {
        transferOwnership(tx.origin);
    }

    function initialize(
        address initialOwner,
        address _feeTaker,
        address iloPoolImplementation,
        address iloPoolSaleImplementation,
        address uniV3Factory,
        address tokenFactory,
        uint256 createProjectFee,
        uint16 platformFee,
        uint16 performanceFee
    ) external override whenNotInitialized {
        INIT_PROJECT_FEE = createProjectFee;
        PLATFORM_FEE = platformFee;
        PERFORMANCE_FEE = performanceFee;
        FEE_TAKER = _feeTaker;
        transferOwnership(initialOwner);
        UNIV3_FACTORY = uniV3Factory;
        ILO_POOL_IMPLEMENTATION = iloPoolImplementation;
        ILO_POOL_SALE_IMPLEMENTATION = iloPoolSaleImplementation;
        TOKEN_FACTORY = tokenFactory;
    }

    /// @inheritdoc IILOManager
    function initProject(
        InitProjectParams calldata params
    ) external payable override afterInitialize {
        require(msg.value == INIT_PROJECT_FEE, 'FEE');
        require(bytes(params.projectId).length != 0, 'ID');
        // transfer fee to fee taker
        payable(FEE_TAKER).transfer(msg.value);

        Project storage _project = _projects[params.projectId];
        require(_project.admin == address(0), 'RE');

        _project.projectId = params.projectId;
        _project.admin = msg.sender;
        _project.pairToken = params.pairToken;
        _project.fee = params.fee;
        _project.initialPoolPriceX96 = params.initialPoolPriceX96;
        _project.platformFee = PLATFORM_FEE;
        _project.performanceFee = PERFORMANCE_FEE;
        _project.status = ProjectStatus.INITIALIZED;
        _project.useTokenFactory = params.useTokenFactory;
        _project.tokenSymbol = params.tokenSymbol;
        _project.totalSupply = params.totalSupply;

        emit ProjectCreated(params.projectId, _project);
    }

    /// @inheritdoc IILOManager
    function initILOPool(
        IILOPoolBase.InitPoolParams calldata params
    )
        external
        override
        onlyProjectAdmin(params.baseParams.projectId)
        onlyInitializedProject(params.baseParams.projectId)
        returns (address poolAddress)
    {
        poolAddress = _deployIloPool(
            params.baseParams,
            ILO_POOL_IMPLEMENTATION
        );
        IILOPool(poolAddress).initialize(params);
        EnumerableSet.add(
            _initializedILOPools[params.baseParams.projectId],
            poolAddress
        );
    }

    /// @inheritdoc IILOManager
    function initILOPoolSale(
        IILOPoolSale.InitParams calldata params
    )
        external
        override
        onlyProjectAdmin(params.baseParams.projectId)
        onlyInitializedProject(params.baseParams.projectId)
        returns (address poolAddress)
    {
        poolAddress = _deployIloPool(
            params.baseParams,
            ILO_POOL_SALE_IMPLEMENTATION
        );

        IILOPoolSale(poolAddress).initialize(params);
        EnumerableSet.add(
            _initializedILOPools[params.baseParams.projectId],
            poolAddress
        );
    }

    function onPoolSaleFail(
        string calldata projectId
    ) external override onlyInitializedPool(projectId) {
        _cancelProject(_projects[projectId]);
    }

    /// @notice this function takes params from ILOPools
    /// and transfer token directly to uniswap v3 pool
    /// without temparory holding in ILOPool
    function iloPoolLaunchCallback(
        string calldata projectId,
        address token0,
        uint256 amount0,
        address token1,
        uint256 amount1,
        address uniswapV3Pool
    ) external override onlyInitializedPool(projectId) {
        Project storage _project = _projects[projectId];
        TransferHelper.safeTransferFrom(
            token0,
            _project.admin,
            uniswapV3Pool,
            amount0
        );
        TransferHelper.safeTransferFrom(
            token1,
            _project.admin,
            uniswapV3Pool,
            amount1
        );
    }

    /// @notice set platform fee for decrease liquidity. Platform fee is imutable among all project's pools
    function setPlatformFee(uint16 _platformFee) external override onlyOwner {
        emit PlatformFeeChanged(PERFORMANCE_FEE, _platformFee);
        PLATFORM_FEE = _platformFee;
    }

    /// @notice set platform fee for decrease liquidity. Platform fee is imutable among all project's pools
    function setPerformanceFee(
        uint16 _performanceFee
    ) external override onlyOwner {
        emit PerformanceFeeChanged(PERFORMANCE_FEE, _performanceFee);
        PERFORMANCE_FEE = _performanceFee;
    }

    /// @notice set platform fee for decrease liquidity. Platform fee is imutable among all project's pools
    function setFeeTaker(address _feeTaker) external override onlyOwner {
        emit FeeTakerChanged(FEE_TAKER, _feeTaker);
        FEE_TAKER = _feeTaker;
    }

    function setILOPoolImplementation(
        address iloPoolImplementation
    ) external override onlyOwner {
        emit PoolImplementationChanged(
            ILO_POOL_IMPLEMENTATION,
            iloPoolImplementation
        );
        ILO_POOL_IMPLEMENTATION = iloPoolImplementation;
    }

    /// @inheritdoc IILOManager
    function setTokenFactory(
        address _tokenFactory
    ) external override onlyOwner {
        emit TokenFactoryChanged(TOKEN_FACTORY, _tokenFactory);
        TOKEN_FACTORY = _tokenFactory;
    }

    function transferAdminProject(
        address admin,
        string calldata projectId
    ) external override onlyProjectAdmin(projectId) {
        _projects[projectId].admin = admin;
        emit ProjectAdminChanged(projectId, msg.sender, admin);
    }

    /// @inheritdoc IILOManager
    function launch(
        string calldata projectId,
        address token
    )
        external
        override
        onlyProjectAdmin(projectId)
        onlyInitializedProject(projectId)
    {
        Project storage _project = _projects[projectId];
        require(
            !_project.useTokenFactory ||
                ITokenFactory(TOKEN_FACTORY).deployedTokens(token),
            'invalid token'
        );
        require(
            _project.totalSupply == IERC20(token).totalSupply(),
            'invalid supply'
        );
        require(
            keccak256(abi.encodePacked(_project.tokenSymbol)) ==
                keccak256(abi.encodePacked(IERC20(token).symbol())),
            'invalid symbol'
        );

        uint160 sqrtPriceX96 = _project.initialPoolPriceX96;
        PoolAddress.PoolKey memory poolKey = PoolAddress.PoolKey(
            token,
            _project.pairToken,
            _project.fee
        );

        // flip price and tokens
        if (token > _project.pairToken) {
            (poolKey.token0, poolKey.token1) = (poolKey.token1, poolKey.token0);
            sqrtPriceX96 = uint160(2 ** 192 / sqrtPriceX96);
        }

        address uniV3PoolAddress = _initUniV3PoolIfNecessary(
            poolKey,
            sqrtPriceX96
        );

        EnumerableSet.AddressSet
            storage initializedPools = _initializedILOPools[projectId];
        uint256 length = EnumerableSet.length(initializedPools);
        require(length > 0, 'NP');
        for (uint256 i = 0; i < length; i++) {
            IILOPoolBase(EnumerableSet.at(initializedPools, i)).launch(
                uniV3PoolAddress,
                poolKey,
                sqrtPriceX96
            );
        }
        _project.status = ProjectStatus.LAUNCHED;
        IUniswapV3Pool(uniV3PoolAddress).increaseObservationCardinalityNext(10);
        emit ProjectLaunch(projectId, uniV3PoolAddress, token);
    }

    function cancelProject(
        string calldata projectId
    )
        external
        override
        ownerOrProjectAdmin(projectId)
        onlyInitializedProject(projectId)
    {
        _cancelProject(_projects[projectId]);
    }

    function removePool(
        string calldata projectId,
        address pool
    )
        external
        override
        onlyInitializedProject(projectId)
        onlyProjectAdmin(projectId)
    {
        EnumerableSet.AddressSet
            storage initializedPools = _initializedILOPools[projectId];
        require(EnumerableSet.contains(initializedPools, pool), 'NP');
        IILOPoolBase(pool).cancel();
        EnumerableSet.remove(initializedPools, pool);
        emit PoolCancelled(projectId, pool);
    }

    /// @inheritdoc IILOManager
    function setInitProjectFee(uint256 fee) external override onlyOwner {
        emit InitProjectFeeChanged(INIT_PROJECT_FEE, fee);
        INIT_PROJECT_FEE = fee;
    }

    /// @inheritdoc IILOManager
    function setFeesForProject(
        string calldata projectId,
        uint16 platformFee,
        uint16 performanceFee
    ) external override onlyOwner {
        Project storage _project = _projects[projectId];
        _project.platformFee = platformFee;
        _project.performanceFee = performanceFee;
        emit FeesForProjectSet(projectId, platformFee, performanceFee);
    }

    function setILOPoolSaleImplementation(
        address iloPoolSaleImplementation
    ) external override onlyOwner {
        emit PoolSaleImplementationChanged(
            ILO_POOL_SALE_IMPLEMENTATION,
            iloPoolSaleImplementation
        );
        ILO_POOL_SALE_IMPLEMENTATION = iloPoolSaleImplementation;
    }

    function project(
        string calldata projectId
    ) external view override returns (Project memory) {
        return _projects[projectId];
    }

    function _deployIloPool(
        IILOPoolBase.InitPoolBaseParams calldata params,
        address implementation
    ) internal returns (address deployedAddress) {
        // dont need to check if project is exist because only project admin can call this function
        Project storage _project = _projects[params.projectId];
        _checkTicks(
            params.tickLower,
            params.tickUpper,
            _project.fee,
            _project.initialPoolPriceX96
        );
        uint256 projectNonce = ++_project.nonce;

        // this salt make sure that pool address can not be represented in any other chains
        bytes32 salt = keccak256(
            abi.encodePacked(ChainId.get(), params.projectId, projectNonce)
        );
        deployedAddress = Clones.cloneDeterministic(implementation, salt);
        emit ILOPoolCreated(params.projectId, deployedAddress);
    }

    function _initUniV3PoolIfNecessary(
        PoolAddress.PoolKey memory poolKey,
        uint160 sqrtPriceX96
    ) internal returns (address pool) {
        pool = IUniswapV3Factory(UNIV3_FACTORY).getPool(
            poolKey.token0,
            poolKey.token1,
            poolKey.fee
        );
        if (pool == address(0)) {
            pool = IUniswapV3Factory(UNIV3_FACTORY).createPool(
                poolKey.token0,
                poolKey.token1,
                poolKey.fee
            );
            IUniswapV3Pool(pool).initialize(sqrtPriceX96);
        } else {
            (uint160 sqrtPriceX96Existing, , , , , , ) = IUniswapV3Pool(pool)
                .slot0();
            if (sqrtPriceX96Existing == 0) {
                IUniswapV3Pool(pool).initialize(sqrtPriceX96);
            } else {
                require(sqrtPriceX96Existing == sqrtPriceX96, 'UV3P');
            }
        }
    }

    function _cancelProject(Project storage _project) internal {
        if (_project.status == ProjectStatus.CANCELLED) {
            return;
        }
        _project.status = ProjectStatus.CANCELLED;
        emit ProjectCancelled(_project.projectId);
    }

    function _checkTicks(
        int24 tickLower,
        int24 tickUpper,
        uint256 fee,
        uint160 sqrtPriceX96
    ) internal pure {
        require(tickLower < tickUpper, 'TLU');

        if (fee == 500) {
            require(tickLower % 10 == 0, 'TL5');
            require(tickUpper % 10 == 0, 'TU5');
        } else if (fee == 3000) {
            require(tickLower % 60 == 0, 'TL3');
            require(tickUpper % 60 == 0, 'TU3');
        } else if (fee == 10000) {
            require(tickLower % 200 == 0, 'TL10');
            require(tickUpper % 200 == 0, 'TU10');
        } else {
            require(fee == 100, 'FEE');
        }

        require(
            sqrtPriceX96 <= TickMath.getSqrtRatioAtTick(tickUpper),
            'RANGE'
        );
    }
}
