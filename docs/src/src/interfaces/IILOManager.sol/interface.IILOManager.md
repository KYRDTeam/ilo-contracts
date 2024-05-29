# IILOManager
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/1de4d92cce6f0722e8736db455733703c706f30f/src/interfaces/IILOManager.sol)

**Inherits:**
[IILOConfig](/src/interfaces/IILOConfig.sol/interface.IILOConfig.md)


## Functions
### initProject


```solidity
function initProject(
    address saleToken,
    address raiseToken,
    uint24 fee,
    uint160 initialPoolPriceX96,
    uint64 launchTime,
    uint16 investorShares,
    ProjectVestConfig[] calldata projectVestConfigs
) external returns (address uniV3PoolAddress);
```

### initILOPool


```solidity
function initILOPool(InitPoolParams calldata params) external;
```

### project


```solidity
function project(address uniV3PoolAddress) external view returns (Project memory);
```

## Events
### ProjectCreated

```solidity
event ProjectCreated(address indexed uniV3PoolAddress, Project project);
```

## Structs
### ProjectVestConfig

```solidity
struct ProjectVestConfig {
    uint16 shares;
    string name;
    address recipient;
    LinearVest[] vestSchedule;
}
```

### Project

```solidity
struct Project {
    address admin;
    address saleToken;
    address raiseToken;
    uint24 fee;
    uint160 initialPoolPriceX96;
    uint64 launchTime;
    uint64 refundDeadline;
    uint16 investorShares;
    ProjectVestConfig[] projectVestConfigs;
    address uniV3PoolAddress;
    PoolAddress.PoolKey _cachedPoolKey;
    uint16 platformFee;
}
```

