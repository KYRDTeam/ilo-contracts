# ILOManager
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/1de4d92cce6f0722e8736db455733703c706f30f/src/ILOManager.sol)

**Inherits:**
[IILOManager](/src/interfaces/IILOManager.sol/interface.IILOManager.md), Ownable


## State Variables
### DEFAULT_DEADLINE_OFFSET

```solidity
uint64 private DEFAULT_DEADLINE_OFFSET = 7 * 24 * 60 * 60;
```


### BPS

```solidity
uint16 constant BPS = 10000;
```


### PLATFORM_FEE

```solidity
uint16 PLATFORM_FEE;
```


### ILO_POOL_IMPLEMENTATION

```solidity
address ILO_POOL_IMPLEMENTATION;
```


### _uniV3Factory

```solidity
address private _uniV3Factory;
```


### _cachedProject

```solidity
mapping(address => Project) private _cachedProject;
```


### _initializedILOPools

```solidity
mapping(address => address[]) private _initializedILOPools;
```


## Functions
### constructor


```solidity
constructor(address initialOwner, address uniV3Factory, uint16 platformFee);
```

### onlyProjectAdmin


```solidity
modifier onlyProjectAdmin(address uniV3Pool);
```

### initProject

init project with details


```solidity
function initProject(
    address saleToken,
    address raiseToken,
    uint24 fee,
    uint160 initialPoolPriceX96,
    uint64 launchTime,
    uint16 investorShares,
    ProjectVestConfig[] calldata projectVestConfigs
) external override returns (address uniV3PoolAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`saleToken`|`address`|the sale token|
|`raiseToken`|`address`|the raise token|
|`fee`|`uint24`|uniswap v3 fee tier|
|`initialPoolPriceX96`|`uint160`|uniswap sqrtPriceX96 for initialize pool|
|`launchTime`|`uint64`|time for lauch all liquidity. Only one launch time for all ilo pools|
|`investorShares`|`uint16`|number of liquidity shares after investor invest into ilo pool interm of BPS = 10000|
|`projectVestConfigs`|`ProjectVestConfig[]`|config for all other shares and vest|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`uniV3PoolAddress`|`address`|address of uniswap v3 pool. We use this address as project id|


### project


```solidity
function project(address uniV3PoolAddress) external view override returns (Project memory);
```

### initILOPool

this function init an `ILO Pool` which will be used for sale and vest. One project can init many ILO Pool

only project admin can use this function


```solidity
function initILOPool(InitPoolParams calldata params) external override onlyProjectAdmin(params.uniV3Pool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`params`|`InitPoolParams`|the parameters for init project|


### _initUniV3PoolIfNecessary


```solidity
function _initUniV3PoolIfNecessary(PoolAddress.PoolKey memory poolKey, uint160 sqrtPriceX96)
    internal
    returns (address pool);
```

### _cacheProject


```solidity
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
) internal;
```

### _validateSharesPercentage


```solidity
function _validateSharesPercentage(uint16 investorShares, ProjectVestConfig[] calldata projectVestConfigs)
    internal
    pure;
```

### _validateVestSchedule


```solidity
function _validateVestSchedule(LinearVest[] memory vestSchedule) internal pure;
```

### setPlatformFee

set platform fee for decrease liquidity. Platform fee is imutable among all project's pools


```solidity
function setPlatformFee(uint16 _platformFee) external onlyOwner;
```

### setILOPoolImplementation

new ilo implementation for clone


```solidity
function setILOPoolImplementation(address iloPoolImplementation) external onlyOwner;
```

### transferAdminProject

transfer admin of project


```solidity
function transferAdminProject(address admin, address uniV3Pool) external;
```

### setDefaultDeadlineOffset

set time offset for refund if project not launch


```solidity
function setDefaultDeadlineOffset(uint64 defaultDeadlineOffset) external onlyOwner;
```

### setRefundDeadlineForProject


```solidity
function setRefundDeadlineForProject(address uniV3Pool, uint64 refundDeadline) external onlyOwner;
```

## Events
### PoolImplementationChanged

```solidity
event PoolImplementationChanged(address indexed oldPoolImplementation, address indexed newPoolImplementation);
```

### ProjectAdminChanged

```solidity
event ProjectAdminChanged(address indexed uniV3PoolAddress, address oldAdmin, address newAdmin);
```

