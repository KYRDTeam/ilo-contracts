// SPDX-License-Identifier: BUSL-1.1 
pragma solidity >=0.7.5;
pragma abicoder v2;

import '../libraries/PoolAddress.sol';
import './IILOVest.sol';

interface IILOManager {

    event ProjectCreated(string projectId, Project project);
    event ILOPoolCreated(string projectId, address indexed iloPoolAddress, uint256 index);
    event PoolImplementationChanged(address indexed oldPoolImplementation, address indexed newPoolImplementation);
    event ProjectAdminChanged(string projectId, address oldAdmin, address newAdmin);
    event DefaultDeadlineOffsetChanged(address indexed owner, uint64 oldDeadlineOffset, uint64 newDeadlineOffset);
    event RefundDeadlineChanged(string projectId, uint64 oldRefundDeadline, uint64 newRefundDeadline);
    event ProjectLaunch(string projectId, address uniswapV3Pool);
    event FeesForProjectSet(string projectId, uint16 platformFee, uint16 performanceFee);

    struct Project {
        string projectId;
        address admin;
        address raiseToken;
        uint24 fee;
        uint160 initialPoolPriceX96;
        uint64 launchTime;
        uint64 refundDeadline;

        uint16 platformFee; // BPS 10000
        uint16 performanceFee; // BPS 10000
    }

    struct InitProjectParams {
        string projectId;
        // the raise token
        address raiseToken;
        // this assume that sale token is token0 which means 1 sale = p * raise
        // initialPoolPriceX96 = sqrt(p) * 2^96
        uint160 initialPoolPriceX96;
        // uniswap v3 fee tier
        uint24 fee;
        // time for lauch all liquidity. Only one launch time for all ilo pools
        uint64 launchTime;
    }

    /// @notice init project with details
    /// @param params the parameters to initialize the project
    function initProject(InitProjectParams calldata params) external payable;

    struct InitPoolParams {
        string projectId;
        int24 tickLower; 
        int24 tickUpper;
        uint256 maxRaise; // total amount of raise tokens
        uint256 minRaise; // minimum amount of raise token needed for launch pool
        uint256 maxRaisePerUser; // TODO: user tiers
        uint64 start;
        uint64 end;

        // config for vests and shares. 
        // First element is allways for investor 
        // and will mint nft when investor buy ilo
        IILOVest.VestingConfig[] vestingConfigs;
    }
    /// @notice this function init an `ILO Pool` which will be used for sale and vest. One project can init many ILO Pool
    /// @notice only project admin can use this function
    /// @param params the parameters for init project
    function initILOPool(InitPoolParams calldata params) external returns(address iloPoolAddress);

    function project(string memory projectId) external view returns (Project memory);

    /// @notice set platform fee for decrease liquidity. Platform fee is imutable among all project's pools
    function setFeeTaker(address _feeTaker) external;

    function UNIV3_FACTORY() external returns(address);
    function WETH9() external returns(address);
    function PLATFORM_FEE() external returns(uint16);
    function PERFORMANCE_FEE() external returns(uint16);
    function FEE_TAKER() external returns(address);
    function ILO_POOL_IMPLEMENTATION() external returns(address);

    function initialize(
        address initialOwner,
        address _feeTaker,
        address iloPoolImplementation,
        address uniV3Factory,
        address weth9,
        uint256 createProjectFee,
        uint16 platformFee,
        uint16 performanceFee
    ) external;

    /// @notice launch all projects
    function launch(string calldata projectId, address saleToken) external;

    /// @notice new ilo implementation for clone
    function setILOPoolImplementation(address iloPoolImplementation) external;

    /// @notice transfer admin of project
    function transferAdminProject(address admin, string calldata projectId) external;

    /// @notice set time offset for refund if project not launch
    function setDefaultDeadlineOffset(uint64 defaultDeadlineOffset) external;
    function setRefundDeadlineForProject(string calldata projectId, uint64 refundDeadline) external;

    /// @notice get fee when init project
    function initProjectFee() external view returns (uint256);
    /// @notice set fee for init project
    function setInitProjectFee(uint256 fee) external;

    /// @notice get fees for a project
    function feesForProject(string calldata projectId) external view returns(uint16 platformFee, uint16 performanceFee);

    /// @notice set fees for project
    function setFeesForProject(
        string calldata projectId,
        uint16 platformFee,
        uint16 performanceFee
    ) external;

    function ILOPoolLaunchCallback(
        string calldata projectId,
        address poolImplementation,
        uint256 poolIndex,
        address saleToken,
        uint256 amount,
        address uniswapV3Pool
    ) external;
}
