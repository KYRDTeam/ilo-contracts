# IPeripheryPaymentsWithFee
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/c821b671bb5c9be46c122173f3f384ce7950f2da/src/interfaces/IPeripheryPaymentsWithFee.sol)

**Inherits:**
[IPeripheryPayments](/src/interfaces/IPeripheryPayments.sol/interface.IPeripheryPayments.md)

Functions to ease deposits and withdrawals of ETH


## Functions
### unwrapWETH9WithFee

Unwraps the contract's WETH9 balance and sends it to recipient as ETH, with a percentage between
0 (exclusive), and 1 (inclusive) going to feeRecipient

*The amountMinimum parameter prevents malicious contracts from stealing WETH9 from users.*


```solidity
function unwrapWETH9WithFee(uint256 amountMinimum, address recipient, uint256 feeBips, address feeRecipient)
    external
    payable;
```

### sweepTokenWithFee

Transfers the full amount of a token held by this contract to recipient, with a percentage between
0 (exclusive) and 1 (inclusive) going to feeRecipient

*The amountMinimum parameter prevents malicious contracts from stealing the token from users*


```solidity
function sweepTokenWithFee(
    address token,
    uint256 amountMinimum,
    address recipient,
    uint256 feeBips,
    address feeRecipient
) external payable;
```

