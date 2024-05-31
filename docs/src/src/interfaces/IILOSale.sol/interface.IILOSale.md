# IILOSale
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/c821b671bb5c9be46c122173f3f384ce7950f2da/src/interfaces/IILOSale.sol)


## Functions
### buy

this function is for investor buying ILO


```solidity
function buy(uint256 raiseAmount, address recipient)
    external
    returns (uint256 tokenId, uint128 liquidity, uint256 amountAdded0, uint256 amountAdded1);
```

## Structs
### SaleInfo

```solidity
struct SaleInfo {
    uint256 hardCap;
    uint256 softCap;
    uint256 maxCapPerUser;
    uint64 start;
    uint64 end;
    uint256 maxSaleAmount;
}
```

