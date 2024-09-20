# IUniswapV3Oracle
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/af88dd9b3e8283ab97b6c9511aeb7bb607e3649d/src/interfaces/IUniswapV3Oracle.sol)


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

