# IUniswapV3Oracle
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/e40a6cd6fab3cc84638afa793f4d9e791b183158/src/interfaces/IUniswapV3Oracle.sol)


## Functions
### PERIOD

TWAP period


```solidity
function PERIOD() external view returns (uint32);
```

### BASE_AMOUNT

Will calculate 1 TK price in ETH


```solidity
function BASE_AMOUNT() external view returns (uint128);
```

### pool

return pool address of base/quote pair


```solidity
function pool() external view returns (address);
```

### token

return token address


```solidity
function token() external view returns (address);
```

### quoteToken

quote token address


```solidity
function quoteToken() external view returns (address);
```

