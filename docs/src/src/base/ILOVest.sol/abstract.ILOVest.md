# ILOVest
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/c821b671bb5c9be46c122173f3f384ce7950f2da/src/base/ILOVest.sol)

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
    uint128 claimedLiquidity;
    LinearVest[] schedule;
}
```

