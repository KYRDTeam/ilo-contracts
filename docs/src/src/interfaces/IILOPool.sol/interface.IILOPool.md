# IILOPool
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/e40a6cd6fab3cc84638afa793f4d9e791b183158/src/interfaces/IILOPool.sol)

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

