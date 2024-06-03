# IILOConfig
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/efdd1e09c11736c5cee1dacbdd6c598f078eeaec/src/interfaces/IILOConfig.sol)


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

