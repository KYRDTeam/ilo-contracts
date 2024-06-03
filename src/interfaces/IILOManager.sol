// SPDX-License-Identifier: BUSL-1.1 
pragma solidity >=0.7.5;
pragma abicoder v2;

import '../libraries/PoolAddress.sol';
import './IILOConfig.sol';

interface IILOManager is IILOConfig {

    event ProjectCreated(address indexed uniV3PoolAddress, Project project);

    struct ProjectVestConfig {
        uint16 shares; // BPS shares
        string name;
        address recipient;
        LinearVest[] vestSchedule;
    }

    struct Project {
        address admin;
        address saleToken;
        address raiseToken;
        uint24 fee;
        uint160 initialPoolPriceX96;
        uint64 launchTime;
        uint64 refundDeadline;
        uint16 investorShares;  // BPS shares
        ProjectVestConfig[] projectVestConfigs;

        // cached info
        address uniV3PoolAddress; // considered as project id
        PoolAddress.PoolKey _cachedPoolKey;
        uint16 platformFee; // BPS 10000
        uint16 performanceFee; // BPS 10000
    }

    struct InitProjectParams {
        // the sale token
        address saleToken;
        // the raise token
        address raiseToken;
        // uniswap v3 fee tier
        uint24 fee;
        // uniswap sqrtPriceX96 for initialize pool
        uint160 initialPoolPriceX96;
        // time for lauch all liquidity. Only one launch time for all ilo pools
        uint64 launchTime;
        // number of liquidity shares after investor invest into ilo pool interm of BPS = 10000
        uint16 investorShares;  // BPS shares
        // config for all other shares and vest
        ProjectVestConfig[] projectVestConfigs;
    }

    /// @notice init project with details
    /// @param params the parameters to initialize the project
    /// @return uniV3PoolAddress address of uniswap v3 pool. We use this address as project id
    function initProject(InitProjectParams calldata params) external returns(address uniV3PoolAddress);

    function initILOPool(InitPoolParams calldata params) external returns(address iloPoolAddress);

    function project(address uniV3PoolAddress) external view returns (Project memory);

    /// @notice set platform fee for decrease liquidity. Platform fee is imutable among all project's pools
    function setFeeTaker(address _feeTaker) external;

    function feeTaker() external returns(address _feeTaker);

    function UNIV3_FACTORY() external returns(address);
    function WETH9() external returns(address);

    function initialize(
        address initialOwner,
        address _feeTaker,
        address uniV3Factory,
        address weth9,
        uint16 platformFee,
        uint16 performanceFee
    ) external;

    /// @notice launch all projects
    function launch(address uniV3PoolAddress) external;
}
