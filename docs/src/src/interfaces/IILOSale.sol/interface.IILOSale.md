# IILOSale
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/be1379a5058f6506f3a229427893748ee4e5ab65/src/interfaces/IILOSale.sol)


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

