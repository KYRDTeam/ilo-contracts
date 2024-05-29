# ILOPoolImmutableState
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/1de4d92cce6f0722e8736db455733703c706f30f/src/base/ILOPoolImmutableState.sol)

**Inherits:**
[IILOPoolImmutableState](/src/interfaces/IILOPoolImmutableState.sol/interface.IILOPoolImmutableState.md)

Immutable state used by periphery contracts


## State Variables
### factory

```solidity
address public immutable override factory;
```


### WETH9

```solidity
address public immutable override WETH9;
```


### MANAGER

```solidity
IILOManager MANAGER;
```


### RAISE_TOKEN

```solidity
address RAISE_TOKEN;
```


### SALE_TOKEN

```solidity
address SALE_TOKEN;
```


### BPS

```solidity
uint16 constant BPS = 10000;
```


### TICK_LOWER

```solidity
int24 TICK_LOWER;
```


### TICK_UPPER

```solidity
int24 TICK_UPPER;
```


### SQRT_RATIO_X96

```solidity
uint160 SQRT_RATIO_X96;
```


### SQRT_RATIO_LOWER_X96

```solidity
uint160 SQRT_RATIO_LOWER_X96;
```


### SQRT_RATIO_UPPER_X96

```solidity
uint160 SQRT_RATIO_UPPER_X96;
```


### PLATFORM_FEE

```solidity
uint16 PLATFORM_FEE;
```


### INVESTOR_SHARES

```solidity
uint16 INVESTOR_SHARES;
```


### _cachedPoolKey

```solidity
PoolAddress.PoolKey private _cachedPoolKey;
```


### _cachedUniV3PoolAddress

```solidity
address private _cachedUniV3PoolAddress;
```


## Functions
### constructor


```solidity
constructor(address _factory, address _WETH9);
```

### _cachePoolKey


```solidity
function _cachePoolKey(PoolAddress.PoolKey memory poolKey) internal;
```

### _poolKey


```solidity
function _poolKey() internal view returns (PoolAddress.PoolKey memory);
```

### _cacheUniV3PoolAddress


```solidity
function _cacheUniV3PoolAddress(address uniV3PoolAddress) internal;
```

### _uniV3PoolAddress


```solidity
function _uniV3PoolAddress() internal view returns (address);
```

