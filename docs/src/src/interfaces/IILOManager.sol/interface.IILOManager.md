# IILOManager
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/c821b671bb5c9be46c122173f3f384ce7950f2da/src/interfaces/IILOManager.sol)

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
function initILOPool(InitPoolParams calldata params) external returns (address iloPoolAddress);
```

### project


```solidity
function project(address uniV3PoolAddress) external view returns (Project memory);
```

### setFeeTaker

set platform fee for decrease liquidity. Platform fee is imutable among all project's pools


```solidity
function setFeeTaker(address _feeTaker) external;
```

### feeTaker


```solidity
function feeTaker() external returns (address _feeTaker);
```

### UNIV3_FACTORY


```solidity
function UNIV3_FACTORY() external returns (address);
```

### WETH9


```solidity
function WETH9() external returns (address);
```

### initialize


```solidity
function initialize(
    address initialOwner,
    address _feeTaker,
    address uniV3Factory,
    address weth9,
    uint16 platformFee,
    uint16 performanceFee
) external;
```

### launch

launch all projects


```solidity
function launch(address uniV3PoolAddress) external;
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
    uint16 performanceFee;
}
```

