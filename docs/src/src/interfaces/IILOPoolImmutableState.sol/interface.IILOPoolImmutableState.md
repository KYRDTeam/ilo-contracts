# IILOPoolImmutableState
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/9e42e9db28c24294412a28a8dafd05701a97c9bc/src/interfaces/IILOPoolImmutableState.sol)

Functions that return immutable state of the router


## Functions
### WETH9


```solidity
function WETH9() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Returns the address of WETH9|


### MANAGER


```solidity
function MANAGER() external view returns (address);
```

### RAISE_TOKEN


```solidity
function RAISE_TOKEN() external view returns (address);
```

### SALE_TOKEN


```solidity
function SALE_TOKEN() external view returns (address);
```

### TICK_LOWER


```solidity
function TICK_LOWER() external view returns (int24);
```

### TICK_UPPER


```solidity
function TICK_UPPER() external view returns (int24);
```

### PLATFORM_FEE


```solidity
function PLATFORM_FEE() external view returns (uint16);
```

### SQRT_RATIO_X96


```solidity
function SQRT_RATIO_X96() external view returns (uint160);
```

### PERFORMANCE_FEE


```solidity
function PERFORMANCE_FEE() external view returns (uint16);
```

### INVESTOR_SHARES


```solidity
function INVESTOR_SHARES() external view returns (uint16);
```

