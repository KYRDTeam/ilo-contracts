# IILOVest
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/af88dd9b3e8283ab97b6c9511aeb7bb607e3649d/src/interfaces/IILOVest.sol)


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

