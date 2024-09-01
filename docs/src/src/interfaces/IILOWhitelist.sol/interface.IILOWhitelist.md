# IILOWhitelist
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/ae631fe4bfbce302e21cc5e317f651168c939703/src/interfaces/IILOWhitelist.sol)


## Functions
### onlyProjectAdmin


```solidity
modifier onlyProjectAdmin() virtual;
```

### setPublicAllocation


```solidity
function setPublicAllocation(uint256 _allocation) external;
```

### setWhiteList


```solidity
function setWhiteList(address[] calldata users, uint256[] calldata allocations) external;
```

### allocation


```solidity
function allocation(address user) external view returns (uint256);
```

### whitelistedCount


```solidity
function whitelistedCount() external view returns (uint256);
```

## Events
### SetWhitelist

```solidity
event SetWhitelist(address indexed user, uint256 allocation);
```

### SetPublicAllocation

```solidity
event SetPublicAllocation(uint256 allocation);
```

