# IILOPool
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/af88dd9b3e8283ab97b6c9511aeb7bb607e3649d/src/interfaces/IILOPool.sol)

**Inherits:**
[IILOPoolBase](/src/interfaces/IILOPoolBase.sol/interface.IILOPoolBase.md)


## Functions
### initialize


```solidity
function initialize(InitPoolParams calldata params) external;
```

## Events
### ILOPoolInitialized

```solidity
event ILOPoolInitialized(
    string projectId, uint256 tokenAmount, int32 tickLower, int32 tickUpper, IILOVest.VestingConfig[] vestingConfig
);
```

