# ILOVest
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/319686becad627d36fa714d2345ca75a5a55cab1/src/base/ILOVest.sol)

**Inherits:**
[IILOConfig](/src/interfaces/IILOConfig.sol/interface.IILOConfig.md)


## State Variables
### _positionVests

```solidity
mapping(uint256 => PositionVest) _positionVests;
```


## Functions
### _unlockedLiquidity


```solidity
function _unlockedLiquidity(uint256 tokenId) internal view virtual returns (uint128 unlockedLiquidity);
```

### _claimableLiquidity


```solidity
function _claimableLiquidity(uint256 tokenId) internal view virtual returns (uint128 claimableLiquidity);
```

### _unlockedSharesBPS

return number of sharesBPS unlocked upto now


```solidity
function _unlockedSharesBPS(LinearVest[] storage vestingSchedule) internal view returns (uint16 unlockedSharesBPS);
```

## Structs
### PositionVest

```solidity
struct PositionVest {
    uint128 totalLiquidity;
    LinearVest[] schedule;
}
```

