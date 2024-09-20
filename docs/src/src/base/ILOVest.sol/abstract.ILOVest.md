# ILOVest
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/af88dd9b3e8283ab97b6c9511aeb7bb607e3649d/src/base/ILOVest.sol)

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

