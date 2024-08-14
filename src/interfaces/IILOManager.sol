// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.7.5;
pragma abicoder v2;

import '../libraries/PoolAddress.sol';
import './IILOVest.sol';

interface IILOManager {
    event ProjectCreated(string projectId, Project project);
    event ILOPoolCreated(string projectId, address indexed pool);
    event PoolImplementationChanged(
        address indexed oldPoolImplementation,
        address indexed newPoolImplementation
    );
    event ProjectAdminChanged(
        string projectId,
        address oldAdmin,
        address newAdmin
    );
    event ProjectLaunch(
        string projectId,
        address uniswapV3Pool,
        address saleToken
    );
    event FeesForProjectSet(
        string projectId,
        uint16 platformFee,
        uint16 performanceFee
    );
    event ProjectCancelled(string projectId);
    event PoolCancelled(string projectId, address pool);
    event SalePoolImplementationChanged(
        address indexed oldSalePoolImplementation,
        address indexed newSalePoolImplementation
    );

    enum ProjectStatus {
        INVALID,
        INITIALIZED,
        LAUNCHED,
        CANCELLED
    }

    struct Project {
        string projectId;
        address admin;
        address pairToken;
        uint24 fee;
        uint160 initialPoolPriceX96;
        uint16 platformFee; // BPS 10000
        uint16 performanceFee; // BPS 10000
        uint16 nonce;
        ProjectStatus status;
    }

    struct InitProjectParams {
        string projectId;
        // the raise token
        address pairToken;
        // this assume that sale token is token0 which means 1 sale = p * raise
        // initialPoolPriceX96 = sqrt(p) * 2^96
        uint160 initialPoolPriceX96;
        // uniswap v3 fee tier
        uint24 fee;
    }

    /// @notice init project with details
    /// @param params the parameters to initialize the project
    function initProject(InitProjectParams calldata params) external payable;

    struct InitPoolParams {
        string projectId;
        uint256 tokenAmount;
        int24 tickLower;
        int24 tickUpper;
        // config for vests and shares.
        IILOVest.VestingConfig[] vestingConfigs;
    }
    /// @notice this function init an `ILO Pool` which will be used for sale and vest. One project can init many ILO Pool
    /// @notice only project admin can use this function
    /// @param params the parameters for init project
    function initILOPool(
        InitPoolParams calldata params
    ) external returns (address iloPoolAddress);

    function project(
        string memory projectId
    ) external view returns (Project memory);

    /// @notice set platform fee for decrease liquidity. Platform fee is imutable among all project's pools
    function setFeeTaker(address _feeTaker) external;

    function UNIV3_FACTORY() external returns (address);
    function PLATFORM_FEE() external returns (uint16);
    function PERFORMANCE_FEE() external returns (uint16);
    function FEE_TAKER() external returns (address);
    function ILO_POOL_IMPLEMENTATION() external returns (address);
    function ILO_POOL_SALE_IMPLEMENTATION() external returns (address);
    function INIT_PROJECT_FEE() external returns (uint256);

    function initialize(
        address initialOwner,
        address _feeTaker,
        address iloPoolImplementation,
        address uniV3Factory,
        uint256 createProjectFee,
        uint16 platformFee,
        uint16 performanceFee
    ) external;

    /// @notice launch all projects
    function launch(string calldata projectId, address saleToken) external;

    /// @notice new ilo implementation for clone
    function setILOPoolImplementation(address iloPoolImplementation) external;

    /// @notice new ilo sale implementation for clone
    function setILOSalePoolImplementation(
        address iloSalePoolImplementation
    ) external;

    /// @notice transfer admin of project
    function transferAdminProject(
        address admin,
        string calldata projectId
    ) external;

    /// @notice cancel project
    function cancelProject(string calldata projectId) external;

    /// @notice cancel pool
    function cancelPoolSale(string calldata projectId, address pool) external;

    function setInitProjectFee(uint256 fee) external;

    /// @notice get fees for a project
    function feesForProject(
        string calldata projectId
    ) external view returns (uint16 platformFee, uint16 performanceFee);

    /// @notice set fees for project
    function setFeesForProject(
        string calldata projectId,
        uint16 platformFee,
        uint16 performanceFee
    ) external;

    function ILOPoolLaunchCallback(
        string calldata projectId,
        address poolImplementation,
        uint256 projectNonce,
        address token0,
        uint256 amount0,
        address token1,
        uint256 amount1,
        address uniswapV3Pool
    ) external;
}
