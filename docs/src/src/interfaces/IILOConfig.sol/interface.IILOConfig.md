# IILOConfig
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/319686becad627d36fa714d2345ca75a5a55cab1/src/interfaces/IILOConfig.sol)


## Structs
### LinearVest

```solidity
struct LinearVest {
    uint16 percentage;
    uint64 start;
    uint64 end;
}
```

### InitPoolParams

```solidity
struct InitPoolParams {
    address uniV3Pool;
    int24 tickLower;
    int24 tickUpper;
    uint256 hardCap;
    uint256 softCap;
    uint256 maxCapPerUser;
    uint64 start;
    uint64 end;
    LinearVest[] investorVestConfigs;
}
```

