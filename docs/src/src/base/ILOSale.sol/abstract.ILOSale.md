# ILOSale
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/319686becad627d36fa714d2345ca75a5a55cab1/src/base/ILOSale.sol)

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
function buy(address payer, uint256 raiseAmount, address recipient)
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

