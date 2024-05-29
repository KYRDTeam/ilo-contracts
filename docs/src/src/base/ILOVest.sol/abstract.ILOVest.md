# ILOVest
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/1de4d92cce6f0722e8736db455733703c706f30f/src/base/ILOVest.sol)

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

