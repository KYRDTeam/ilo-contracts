# IILOPool
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/ae631fe4bfbce302e21cc5e317f651168c939703/src/interfaces/IILOPool.sol)

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

