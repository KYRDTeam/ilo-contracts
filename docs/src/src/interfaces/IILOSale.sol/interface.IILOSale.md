# IILOSale
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/1de4d92cce6f0722e8736db455733703c706f30f/src/interfaces/IILOSale.sol)


## Functions
### buy

this function is for investor buying ILO


```solidity
function buy(BuyParams calldata params)
    external
    returns (uint256 tokenId, uint128 liquidity, uint256 amountAdded0, uint256 amountAdded1);
```

## Structs
### BuyParams

```solidity
struct BuyParams {
    uint256 raiseAmount;
    address recipient;
}
```

