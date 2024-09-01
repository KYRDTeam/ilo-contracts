# ILOPoolImmutableState
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/ae631fe4bfbce302e21cc5e317f651168c939703/src/base/ILOPoolImmutableState.sol)

**Inherits:**
[IILOPoolImmutableState](/src/interfaces/IILOPoolImmutableState.sol/interface.IILOPoolImmutableState.md)

Immutable state used by periphery contracts


## State Variables
### PROJECT_ID

```solidity
string public override PROJECT_ID;
```


### MANAGER

```solidity
address public override MANAGER;
```


### PAIR_TOKEN

```solidity
address public override PAIR_TOKEN;
```


### TICK_LOWER

```solidity
int24 public override TICK_LOWER;
```


### TICK_UPPER

```solidity
int24 public override TICK_UPPER;
```


### IMPLEMENTATION

```solidity
address public override IMPLEMENTATION;
```


### PROJECT_NONCE

```solidity
uint256 public override PROJECT_NONCE;
```


### _cachedUniV3PoolAddress

```solidity
address internal _cachedUniV3PoolAddress;
```


### _cachedPoolKey

```solidity
PoolAddress.PoolKey internal _cachedPoolKey;
```


## Functions
### _initializeImmutableState


```solidity
function _initializeImmutableState(string memory projectId, address manager, int24 tickLower, int24 tickUpper)
    internal;
```

### _initImplementation

this function to be implemented in the ilo pool and ilo pool sale
each contract will have its own implementation


```solidity
function _initImplementation() internal virtual;
```

### _flipTicks


```solidity
function _flipTicks() internal;
```

### _sqrtRatioLowerX96


```solidity
function _sqrtRatioLowerX96() internal view returns (uint160 sqrtRatioLowerX96);
```

### _sqrtRatioUpperX96


```solidity
function _sqrtRatioUpperX96() internal view returns (uint160 sqrtRatioUpperX96);
```

