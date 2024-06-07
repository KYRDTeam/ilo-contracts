# ILOPoolImmutableState
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/9e42e9db28c24294412a28a8dafd05701a97c9bc/src/base/ILOPoolImmutableState.sol)

**Inherits:**
[IILOPoolImmutableState](/src/interfaces/IILOPoolImmutableState.sol/interface.IILOPoolImmutableState.md)

Immutable state used by periphery contracts


## State Variables
### WETH9

```solidity
address public override WETH9;
```


### BPS

```solidity
uint16 constant BPS = 10000;
```


### MANAGER

```solidity
address public override MANAGER;
```


### RAISE_TOKEN

```solidity
address public override RAISE_TOKEN;
```


### SALE_TOKEN

```solidity
address public override SALE_TOKEN;
```


### TICK_LOWER

```solidity
int24 public override TICK_LOWER;
```


### TICK_UPPER

```solidity
int24 public override TICK_UPPER;
```


### SQRT_RATIO_X96

```solidity
uint160 public override SQRT_RATIO_X96;
```


### SQRT_RATIO_LOWER_X96

```solidity
uint160 internal SQRT_RATIO_LOWER_X96;
```


### SQRT_RATIO_UPPER_X96

```solidity
uint160 internal SQRT_RATIO_UPPER_X96;
```


### PLATFORM_FEE

```solidity
uint16 public override PLATFORM_FEE;
```


### PERFORMANCE_FEE

```solidity
uint16 public override PERFORMANCE_FEE;
```


### INVESTOR_SHARES

```solidity
uint16 public override INVESTOR_SHARES;
```


### _cachedPoolKey

```solidity
PoolAddress.PoolKey internal _cachedPoolKey;
```


### _cachedUniV3PoolAddress

```solidity
address internal _cachedUniV3PoolAddress;
```


