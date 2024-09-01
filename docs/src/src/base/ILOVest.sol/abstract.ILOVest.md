# ILOVest
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/ae631fe4bfbce302e21cc5e317f651168c939703/src/base/ILOVest.sol)

**Inherits:**
[IILOVest](/src/interfaces/IILOVest.sol/interface.IILOVest.md), [BasisPoint](/src/base/BasisPoint.sol/abstract.BasisPoint.md)


## State Variables
### _positionVests

```solidity
mapping(uint256 => PositionVest) internal _positionVests;
```


## Functions
### _validateSharesAndVests


```solidity
function _validateSharesAndVests(VestingConfig[] memory vestingConfigs) internal pure;
```

### _validateVestSchedule


```solidity
function _validateVestSchedule(LinearVest[] memory schedule) internal pure;
```

