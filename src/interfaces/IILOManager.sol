// SPDX-License-Identifier: MIT 
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
    }

    function initProject(
        address saleToken,
        address raiseToken,
        uint24 fee,
        uint160 initialPoolPriceX96,
        uint64 launchTime,
        uint16 investorShares,  // BPS shares
        ProjectVestConfig[] calldata projectVestConfigs
    ) external returns(address uniV3PoolAddress);

    function initILOPool(InitPoolParams calldata params) external;

    function project(address uniV3PoolAddress) external view returns (Project memory);
}
