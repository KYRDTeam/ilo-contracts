# ILOSale
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/1de4d92cce6f0722e8736db455733703c706f30f/src/base/ILOSale.sol)

**Inherits:**
[IILOSale](/src/interfaces/IILOSale.sol/interface.IILOSale.md)


## State Variables
### saleInfo

```solidity
SaleInfo saleInfo;
```


## Functions
### buy

this function is for investor buying ILO


```solidity
function buy(BuyParams calldata params)
    external
    virtual
    override
    returns (uint256 tokenId, uint128 liquidity, uint256 amountAdded0, uint256 amountAdded1);
```

### beforeSale


```solidity
modifier beforeSale();
```

### afterSale


```solidity
modifier afterSale();
```

### duringSale


```solidity
modifier duringSale();
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

