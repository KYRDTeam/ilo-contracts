// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.7.6;
pragma abicoder v2;

import "./interfaces/IILOManager.sol";
import "./interfaces/IILOPool.sol";
import "./libraries/ChainId.sol";
import './base/Initializable.sol';
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol';
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';
import '@uniswap/v3-core/contracts/libraries/TickMath.sol';
import "@openzeppelin/contracts/access/Ownable.sol";
import '@openzeppelin/contracts/proxy/Clones.sol';

contract ILOManager is IILOManager, Ownable, Initializable {
    address public override UNIV3_FACTORY;
    address public override WETH9;

    uint64 private DEFAULT_DEADLINE_OFFSET = 7 * 24 * 60 * 60; // 7 days
    uint16 public override PLATFORM_FEE;
    uint16 public override PERFORMANCE_FEE;
    address public override FEE_TAKER;
    address public override ILO_POOL_IMPLEMENTATION;
    uint256 private _initProjectFee;

    mapping(string => Project) private _projects; // map projectId => project)
    mapping(string => address[]) private _initializedILOPools; // map projectId => list of initialized ilo pools

    /// @dev since deploy via deployer so we need to claim ownership
    constructor () {
        transferOwnership(tx.origin);
    }

    function initialize(
        address initialOwner,
        address _feeTaker,
        address iloPoolImplementation,
        address uniV3Factory,
        address weth9,
        uint256 createProjectFee,
        uint16 platformFee,
        uint16 performanceFee
    ) external override whenNotInitialized() {
        _initProjectFee = createProjectFee;
        PLATFORM_FEE = platformFee;
        PERFORMANCE_FEE = performanceFee;
        FEE_TAKER = _feeTaker;
        transferOwnership(initialOwner);
        UNIV3_FACTORY = uniV3Factory;
        ILO_POOL_IMPLEMENTATION = iloPoolImplementation;
        WETH9 = weth9;
    }

    modifier onlyProjectAdmin(string calldata projectId) {
        require(_projects[projectId].admin == msg.sender, "UA");
        _;
    }

    /// @inheritdoc IILOManager
    function initProject(InitProjectParams calldata params) external payable override afterInitialize() {
        require(msg.value == _initProjectFee, "FEE");
        // transfer fee to fee taker
        payable(FEE_TAKER).transfer(msg.value);
        
        Project storage _project = _projects[params.projectId];
        require(_project.admin == address(0), "RE");

        _project.projectId = params.projectId;
        _project.admin = msg.sender;
        _project.raiseToken = params.raiseToken;
        _project.fee = params.fee;
        _project.initialPoolPriceX96 = params.initialPoolPriceX96;
        _project.launchTime = params.launchTime;
        _project.refundDeadline = params.launchTime + DEFAULT_DEADLINE_OFFSET;
        _project.platformFee = PLATFORM_FEE;
        _project.performanceFee = PERFORMANCE_FEE;

        emit ProjectCreated(params.projectId, _project);
    }

    function project(string calldata projectId) external override view returns (Project memory) {
        return _projects[projectId];
    }

    /// @inheritdoc IILOManager
    function initILOPool(InitPoolParams calldata params) external override onlyProjectAdmin(params.projectId) returns (address iloPoolAddress) {
        // dont need to check if project is exist because only project admin can call this function
        Project storage _project = _projects[params.projectId];
        _checkTicks(params.tickLower, params.tickUpper, _project.fee);
        {
            // validate time for sale start and end compared to launch time
            require(params.start < params.end && params.end < _project.launchTime, "PT");
            // this salt make sure that pool address can not be represented in any other chains
            bytes32 salt = keccak256(abi.encodePacked(
                ChainId.get(),
                params.projectId,
                _initializedILOPools[params.projectId].length
            ));
            iloPoolAddress = Clones.cloneDeterministic(ILO_POOL_IMPLEMENTATION, salt);
            emit ILOPoolCreated(params.projectId, iloPoolAddress, _initializedILOPools[params.projectId].length);
        }

        IILOPool.InitPoolParams memory initParams = IILOPool.InitPoolParams({
            projectId: params.projectId,
            tickLower: params.tickLower,
            tickUpper: params.tickUpper,
            maxRaise: params.maxRaise,
            minRaise: params.minRaise,
            maxRaisePerUser: params.maxRaisePerUser,
            start: params.start,
            end: params.end,
            vestingConfigs: params.vestingConfigs
        });
        IILOPool(iloPoolAddress).initialize(initParams);
        _initializedILOPools[params.projectId].push(iloPoolAddress);
    }

    function _checkTicks(int24 tickLower, int24 tickUpper, uint256 fee) internal pure {
        require(tickLower < tickUpper, 'TLU');
        require(tickLower >= TickMath.MIN_TICK, 'TLM');
        require(tickUpper <= TickMath.MAX_TICK, 'TUM');

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
    }

    function _initUniV3PoolIfNecessary(PoolAddress.PoolKey memory poolKey, uint160 sqrtPriceX96) internal returns (address pool) {
        pool = IUniswapV3Factory(UNIV3_FACTORY).getPool(poolKey.token0, poolKey.token1, poolKey.fee);
        if (pool == address(0)) {
            pool = IUniswapV3Factory(UNIV3_FACTORY).createPool(poolKey.token0, poolKey.token1, poolKey.fee);
            IUniswapV3Pool(pool).initialize(sqrtPriceX96);
        } else {
            (uint160 sqrtPriceX96Existing, , , , , , ) = IUniswapV3Pool(pool).slot0();
            if (sqrtPriceX96Existing == 0) {
                IUniswapV3Pool(pool).initialize(sqrtPriceX96);
            } else {
                require(sqrtPriceX96Existing == sqrtPriceX96, "UV3P");
            }
        }
    }

    /// @notice set platform fee for decrease liquidity. Platform fee is imutable among all project's pools
    function setPlatformFee(uint16 _platformFee) external onlyOwner() {
        PLATFORM_FEE = _platformFee;
    }

    /// @notice set platform fee for decrease liquidity. Platform fee is imutable among all project's pools
    function setPerformanceFee(uint16 _performanceFee) external onlyOwner() {
        PERFORMANCE_FEE = _performanceFee;
    }

    /// @notice set platform fee for decrease liquidity. Platform fee is imutable among all project's pools
    function setFeeTaker(address _feeTaker) external override onlyOwner() {
        FEE_TAKER = _feeTaker;
    }

    function setILOPoolImplementation(address iloPoolImplementation) external override onlyOwner() {
        emit PoolImplementationChanged(ILO_POOL_IMPLEMENTATION, iloPoolImplementation);
        ILO_POOL_IMPLEMENTATION = iloPoolImplementation;
    }

    function transferAdminProject(address admin, string calldata projectId) external override onlyProjectAdmin(projectId) {
        _projects[projectId].admin = admin;
        emit ProjectAdminChanged(projectId, msg.sender, admin);
    }

    function setDefaultDeadlineOffset(uint64 defaultDeadlineOffset) external override onlyOwner() {
        emit DefaultDeadlineOffsetChanged(owner(), DEFAULT_DEADLINE_OFFSET, defaultDeadlineOffset);
        DEFAULT_DEADLINE_OFFSET = defaultDeadlineOffset;
    }

    function setRefundDeadlineForProject(string calldata projectId, uint64 refundDeadline) external override onlyOwner() {
        Project storage _project = _projects[projectId];
        emit RefundDeadlineChanged(projectId, _project.refundDeadline, refundDeadline);
        _project.refundDeadline = refundDeadline;
    }

    /// @inheritdoc IILOManager
    function launch(string calldata projectId, address saleToken) external override {
        require(block.timestamp > _projects[projectId].launchTime, "LT");
        require(msg.sender == _projects[projectId].admin, "UA");

        uint160 sqrtPriceX96 = _projects[projectId].initialPoolPriceX96;
        PoolAddress.PoolKey memory poolKey = PoolAddress.PoolKey(saleToken, _projects[projectId].raiseToken, _projects[projectId].fee);
        
        // flip price and tokens
        if (saleToken > _projects[projectId].raiseToken) {
            (poolKey.token0, poolKey.token1) = (poolKey.token1, poolKey.token0);
            sqrtPriceX96 = uint160(2**192 / sqrtPriceX96);
        }

        address uniV3PoolAddress = _initUniV3PoolIfNecessary(poolKey, sqrtPriceX96);

        address[] memory initializedPools = _initializedILOPools[projectId];
        require(initializedPools.length > 0, "NP");
        for (uint256 i = 0; i < initializedPools.length; i++) {
            IILOPool(initializedPools[i]).launch(projectId, uniV3PoolAddress, poolKey);
        }

        emit ProjectLaunch(projectId, uniV3PoolAddress);
    }
    
    /// @inheritdoc IILOManager
    function initProjectFee() external override view returns (uint256) {
        return _initProjectFee;
    }
    
    /// @inheritdoc IILOManager
    function setInitProjectFee(uint256 fee) external override onlyOwner() {
        _initProjectFee = fee;
    }

    /// @inheritdoc IILOManager
    function setFeesForProject(string calldata projectId, uint16 platformFee, uint16 performanceFee) external override onlyOwner() {
        Project storage _project = _projects[projectId];
        _project.platformFee = platformFee;
        _project.performanceFee = performanceFee;
        emit FeesForProjectSet(projectId, platformFee, performanceFee);
    }

    /// @inheritdoc IILOManager
    function feesForProject(string calldata projectId) external override view returns (uint16, uint16) {
        Project storage _project = _projects[projectId];
        return (_project.platformFee, _project.performanceFee);
    }
}
