# IUniswapV3Oracle
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/ae631fe4bfbce302e21cc5e317f651168c939703/src/interfaces/IUniswapV3Oracle.sol)


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

