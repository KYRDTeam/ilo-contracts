// SPDX-License-Identifier: MIT 
pragma solidity >=0.7.5;
pragma abicoder v2;

import '../libraries/PoolAddress.sol';

interface IILOManager {

    event ProjectCreated(address indexed uniV3PoolAddress, Project project);

    struct LinearVest {
        uint8 percentage;
        uint64 start;
        uint64 end;
    }

    struct ProjectVest {
        string name;
        uint8 shares; // percentage
    }

    struct Project {
        address saleToken;
        address raiseToken;
        uint24 fee;
        uint160 initialPoolPriceX96;
        uint64 launchTime;
        uint64 refundDeadline;
        uint8 investorShares;  // percentage of user shares
        LinearVest[] projectVestConfigs;
        
        address uniV3PoolAddress; // considered as project id
        PoolAddress.PoolKey _cachedPoolKey;
    }

    function initProject(
        address saleToken,
        address raiseToken,
        uint24 fee,
        uint160 initialPoolPriceX96,
        uint64 launchTime,
        uint64 refundDeadline,
        uint8 investorShares,  // percentage of user shares
        LinearVest[] calldata projectVestConfigs
    ) external returns(address uniV3PoolAddress);

    function initILOPool(
        uint256 projectId,
        address poolAdmin,
        int24 tickLower,
        int24 tickUpper,
        uint256 hardCap, // total amount of raise tokens
        uint256 softCap, // minimum amount of raise token needed for launch pool
        uint256 maxCapPerUser, // TODO: user tiers
        uint64 start,
        uint64 end,
        LinearVest[] calldata investorVestConfigs
    ) external;

    function project(address uniV3PoolAddress) external view returns (Project memory);
}
