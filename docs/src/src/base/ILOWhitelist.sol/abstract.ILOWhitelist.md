# ILOWhitelist
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/1de4d92cce6f0722e8736db455733703c706f30f/src/base/ILOWhitelist.sol)


## State Variables
### _whitelisted

```solidity
EnumerableSet.AddressSet private _whitelisted;
```


## Functions
### onlyWhitelisted


```solidity
modifier onlyWhitelisted(address user);
```

### isWhitelisted

check if the address is whitelisted


```solidity
function isWhitelisted(address user) external view returns (bool);
```

### setWhitelist


```solidity
function setWhitelist(address user) external;
```

### removeWhitelist


```solidity
function removeWhitelist(address user) external;
```

### batchWhitelist


```solidity
function batchWhitelist(address[] calldata users) external;
```

### batchRemoveWhitelist


```solidity
function batchRemoveWhitelist(address[] calldata users) external;
```

### _removeWhitelist


```solidity
function _removeWhitelist(address user) internal;
```

### _setWhitelist


```solidity
function _setWhitelist(address user) internal;
```

## Events
### SetWhitelist

```solidity
event SetWhitelist(address indexed user, bool isWhitelist);
```

