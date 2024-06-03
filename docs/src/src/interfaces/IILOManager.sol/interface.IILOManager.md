# IILOManager
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/be1379a5058f6506f3a229427893748ee4e5ab65/src/interfaces/IILOManager.sol)

**Inherits:**
[IILOConfig](/src/interfaces/IILOConfig.sol/interface.IILOConfig.md)


## Functions
### initProject

init project with details


```solidity
function initProject(InitProjectParams calldata params) external returns (address uniV3PoolAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`params`|`InitProjectParams`|the parameters to initialize the project|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`uniV3PoolAddress`|`address`|address of uniswap v3 pool. We use this address as project id|


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
    address iloPoolImplementation,
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

### InitProjectParams

```solidity
struct InitProjectParams {
    address saleToken;
    address raiseToken;
    uint24 fee;
    uint160 initialPoolPriceX96;
    uint64 launchTime;
    uint16 investorShares;
    ProjectVestConfig[] projectVestConfigs;
}
```

