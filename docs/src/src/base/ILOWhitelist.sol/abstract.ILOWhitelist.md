# ILOWhitelist
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/ae631fe4bfbce302e21cc5e317f651168c939703/src/base/ILOWhitelist.sol)

**Inherits:**
[IILOWhitelist](/src/interfaces/IILOWhitelist.sol/interface.IILOWhitelist.md)


## State Variables
### _whitelistCount

```solidity
uint256 private _whitelistCount;
```


### PUBLIC_ALLOCATION

```solidity
uint256 public PUBLIC_ALLOCATION;
```


### _userAllocation

```solidity
mapping(address => uint256) private _userAllocation;
```


## Functions
### setPublicAllocation


```solidity
function setPublicAllocation(uint256 _allocation) external override onlyProjectAdmin;
```

### setWhiteList


```solidity
function setWhiteList(address[] calldata users, uint256[] calldata allocations) external override onlyProjectAdmin;
```

### whitelistedCount


```solidity
function whitelistedCount() external view override returns (uint256);
```

### allocation


```solidity
function allocation(address user) public view override returns (uint256);
```

### _setWhitelist


```solidity
function _setWhitelist(address user, uint256 _allocation) internal;
```

### _removeWhitelist


```solidity
function _removeWhitelist(address user) internal;
```

