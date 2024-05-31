// SPDX-License-Identifier: BSL-1.1
pragma solidity =0.7.6;
pragma abicoder v2;

import "./interfaces/IILOManager.sol";
import "./interfaces/IILOPool.sol";
import "./libraries/ChainId.sol";
import './base/Initializable.sol';
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol';
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';
import "@openzeppelin/contracts/access/Ownable.sol";
import '@openzeppelin/contracts/proxy/Clones.sol';

contract ILOManager is IILOManager, Ownable, Initializable {

    event PoolImplementationChanged(address indexed oldPoolImplementation, address indexed newPoolImplementation);
    event ProjectAdminChanged(address indexed uniV3PoolAddress, address oldAdmin, address newAdmin);

    address public override UNIV3_FACTORY;
    address public override WETH9;

    uint64 private DEFAULT_DEADLINE_OFFSET = 7 * 24 * 60 * 60; // 7 days
    uint16 constant BPS = 10000;
    uint16 PLATFORM_FEE;
    uint16 PERFORMANCE_FEE;
    address FEE_TAKER;
    address ILO_POOL_IMPLEMENTATION;

    mapping(address => Project) private _cachedProject; // map uniV3Pool => project (aka projectId => project)
    mapping(address => address[]) private _initializedILOPools; // map uniV3Pool => list of initialized ilo pools

    /// @dev since deploy via deployer so we need to claim ownership
    constructor () public {
        transferOwnership(tx.origin);
    }

    function initialize(
        address initialOwner,
        address _feeTaker,
        address uniV3Factory,
        address weth9,
        uint16 platformFee,
        uint16 performanceFee
    ) external override whenNotInitialized() {
        PLATFORM_FEE = platformFee;
        PERFORMANCE_FEE = performanceFee;
        FEE_TAKER = _feeTaker;
        transferOwnership(initialOwner);
        UNIV3_FACTORY = uniV3Factory;
        WETH9 = weth9;
    }

    modifier onlyProjectAdmin(address uniV3Pool) {
        require(_cachedProject[uniV3Pool].admin == msg.sender, "unauthorized");
        _;
    }

    /// @notice init project with details
    /// @param saleToken the sale token
    /// @param raiseToken the raise token
    /// @param fee uniswap v3 fee tier
    /// @param initialPoolPriceX96 uniswap sqrtPriceX96 for initialize pool
    /// @param launchTime time for lauch all liquidity. Only one launch time for all ilo pools
    /// @param investorShares number of liquidity shares after investor invest into ilo pool interm of BPS = 10000
    /// @param projectVestConfigs config for all other shares and vest
    /// @return uniV3PoolAddress address of uniswap v3 pool. We use this address as project id
    function initProject (
        address saleToken,
        address raiseToken,
        uint24 fee,
        uint160 initialPoolPriceX96,
        uint64 launchTime,
        uint16 investorShares,  // percentage of user shares
        ProjectVestConfig[] calldata projectVestConfigs
    ) external override afterInitialize() returns(address uniV3PoolAddress) {

        _validateSharesPercentage(investorShares, projectVestConfigs);
        uint64 refundDeadline = launchTime + DEFAULT_DEADLINE_OFFSET;

        PoolAddress.PoolKey memory poolKey = PoolAddress.getPoolKey(saleToken, raiseToken, fee);
        uniV3PoolAddress = _initUniV3PoolIfNecessary(poolKey, initialPoolPriceX96);
        
        _cacheProject(uniV3PoolAddress, saleToken, raiseToken, fee, initialPoolPriceX96, launchTime, refundDeadline, investorShares, projectVestConfigs);
        emit ProjectCreated(uniV3PoolAddress, _cachedProject[uniV3PoolAddress]);
    }

    function project(address uniV3PoolAddress) external override view returns (Project memory) {
        return _cachedProject[uniV3PoolAddress];
    }

    /// @notice this function init an `ILO Pool` which will be used for sale and vest. One project can init many ILO Pool
    /// @notice only project admin can use this function
    /// @param params the parameters for init project
    function initILOPool(InitPoolParams calldata params) external override onlyProjectAdmin(params.uniV3Pool) returns (address iloPoolAddress) {
        require(ILO_POOL_IMPLEMENTATION != address(0), "no pool implementation!");

        // validate time for sale start and end compared to launch time
        Project storage _project = _cachedProject[params.uniV3Pool];
        require(_project.uniV3PoolAddress != address(0), "project not initialized");
        require(params.start < params.end && params.end < _project.launchTime, "invalid time configs");
        // this salt make sure that pool address can not be represented in any other chains
        bytes32 salt = keccak256(abi.encodePacked(
            ChainId.get(),
            params.uniV3Pool,
            _initializedILOPools[params.uniV3Pool].length
        ));
        iloPoolAddress = Clones.cloneDeterministic(ILO_POOL_IMPLEMENTATION, salt);
        IILOPool(iloPoolAddress).initialize(params);
        _initializedILOPools[params.uniV3Pool].push(iloPoolAddress);
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
            } else if (sqrtPriceX96Existing != sqrtPriceX96) {
                revert("uni v3 pool already exists");
            }
        }
    }

    function _cacheProject(
        address uniV3PoolAddress,
        address saleToken,
        address raiseToken,
        uint24 fee,
        uint160 initialPoolPriceX96,
        uint64 launchTime,
        uint64 refundDeadline,
        uint16 investorShares,
        ProjectVestConfig[] calldata projectVestConfigs
    ) internal {
        Project storage _project = _cachedProject[uniV3PoolAddress];
        require(_project.uniV3PoolAddress == address(0), "project already initialized");

        uint256 projectVestConfigsLength = projectVestConfigs.length;
        for (uint256 index = 0; index < projectVestConfigsLength; index++) {
            _project.projectVestConfigs.push(projectVestConfigs[index]);
        }

        _project.platformFee = PLATFORM_FEE;
        _project.admin = msg.sender;
        _project.saleToken = saleToken;
        _project.raiseToken = raiseToken;
        _project.fee = fee;
        _project.initialPoolPriceX96 = initialPoolPriceX96;
        _project.launchTime = launchTime;
        _project.refundDeadline = refundDeadline;
        _project.investorShares = investorShares;
        _project.uniV3PoolAddress = uniV3PoolAddress;
    }

    function _validateSharesPercentage(uint16 investorShares, ProjectVestConfig[] calldata projectVestConfigs) internal pure {
        require(investorShares <= BPS);
        uint16 totalShares = investorShares;
        uint256 configLength = projectVestConfigs.length;
        for (uint256 index = 0; index < configLength; index++) {
            // we need to subtract fist in order to avoid int overflow
            require(BPS - totalShares >= projectVestConfigs[index].shares);
            _validateVestSchedule(projectVestConfigs[index].vestSchedule);
            totalShares += projectVestConfigs[index].shares;
        }
        // total shares should be exactly equal BPS
        require(totalShares == BPS);
    }

    function _validateVestSchedule(LinearVest[] memory vestSchedule) internal pure {
        require(vestSchedule.length > 0);
        uint16 totalShares;
        uint64 lastEnd;
        uint256 vestScheduleLength = vestSchedule.length;
        for (uint256 index = 0; index < vestScheduleLength; index++) {
            // vesting schedule must not overlap
            require(vestSchedule[index].start > lastEnd);
            lastEnd = vestSchedule[index].end;
            // we need to subtract fist in order to avoid int overflow
            require(BPS - totalShares >= vestSchedule[index].percentage);
            totalShares += vestSchedule[index].percentage;
        }
        // total shares should be exactly equal BPS
        require(totalShares == BPS);
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

    function feeTaker() external view override returns(address _feeTaker) {
        return FEE_TAKER;
    }

    /// @notice new ilo implementation for clone
    function setILOPoolImplementation(address iloPoolImplementation) external onlyOwner() {
        emit PoolImplementationChanged(ILO_POOL_IMPLEMENTATION, iloPoolImplementation);
        ILO_POOL_IMPLEMENTATION = iloPoolImplementation;
    }

    /// @notice transfer admin of project
    function transferAdminProject(address admin, address uniV3Pool) external {
        Project storage _project = _cachedProject[uniV3Pool];
        require(msg.sender == _project.admin);
        _project.admin = admin;
        emit ProjectAdminChanged(uniV3Pool, msg.sender, _project.admin);
    }

    /// @notice set time offset for refund if project not launch
    function setDefaultDeadlineOffset(uint64 defaultDeadlineOffset) external onlyOwner() {
        DEFAULT_DEADLINE_OFFSET = defaultDeadlineOffset;
        // TODO: emit event when the defaultDeadlineOffset changes
    }

    function setRefundDeadlineForProject(address uniV3Pool, uint64 refundDeadline) external onlyOwner() {
        Project storage _project = _cachedProject[uniV3Pool];
        _project.refundDeadline = refundDeadline;
        // TODO: emit event when the refundDeadline changes
    }

    /// @inheritdoc IILOManager
    function launch(address uniV3PoolAddress) external override {
        require(block.timestamp > _cachedProject[uniV3PoolAddress].launchTime);
        address[] memory initializedPools = _initializedILOPools[uniV3PoolAddress];
        for (uint256 i = 0; i < initializedPools.length; i++) {
            IILOPool(initializedPools[i]).launch();
        }
    }
}
