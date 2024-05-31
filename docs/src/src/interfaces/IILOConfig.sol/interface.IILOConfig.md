# IILOConfig
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/a3fc4c57db039cc1b79c7925531b021576d1b1a7/src/interfaces/IILOConfig.sol)


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

