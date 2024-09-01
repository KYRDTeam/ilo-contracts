# IILOVest
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/e40a6cd6fab3cc84638afa793f4d9e791b183158/src/interfaces/IILOVest.sol)


## Structs
### VestingConfig

```solidity
struct VestingConfig {
    uint16 shares;
    address recipient;
    LinearVest[] schedule;
}
```

### LinearVest

```solidity
struct LinearVest {
    uint16 shares;
    uint64 start;
    uint64 end;
}
```

### PositionVest

```solidity
struct PositionVest {
    uint128 totalLiquidity;
    LinearVest[] schedule;
}
```

