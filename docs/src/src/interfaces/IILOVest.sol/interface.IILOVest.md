# IILOVest
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/ae631fe4bfbce302e21cc5e317f651168c939703/src/interfaces/IILOVest.sol)


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

