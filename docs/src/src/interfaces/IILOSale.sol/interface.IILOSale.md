# IILOSale
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/da7613c22bad547ebd26a45d76010fc3957237e9/src/interfaces/IILOSale.sol)


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

