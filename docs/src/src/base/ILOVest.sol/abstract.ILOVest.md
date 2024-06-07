# ILOVest
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/9e42e9db28c24294412a28a8dafd05701a97c9bc/src/base/ILOVest.sol)

**Inherits:**
[IILOConfig](/src/interfaces/IILOConfig.sol/interface.IILOConfig.md)


## State Variables
### _positionVests

```solidity
mapping(uint256 => PositionVest) _positionVests;
```


## Functions
### _unlockedLiquidity

calculate amount of liquidity unlocked for claim


```solidity
function _unlockedLiquidity(uint256 tokenId) internal view virtual returns (uint128 liquidityUnlocked);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|nft token id of position|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`liquidityUnlocked`|`uint128`|amount of unlocked liquidity|


### _claimableLiquidity


```solidity
function _claimableLiquidity(uint256 tokenId) internal view virtual returns (uint128 claimableLiquidity);
```

## Structs
### PositionVest

```solidity
struct PositionVest {
    uint128 totalLiquidity;
    LinearVest[] schedule;
}
```

