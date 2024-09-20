# LiquidityManagement
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/af88dd9b3e8283ab97b6c9511aeb7bb607e3649d/src/base/LiquidityManagement.sol)

**Inherits:**
IUniswapV3MintCallback, [ILOPoolImmutableState](/src/base/ILOPoolImmutableState.sol/abstract.ILOPoolImmutableState.md)

Internal functions for safely managing liquidity in Uniswap V3


## Functions
### uniswapV3MintCallback

Called to `msg.sender` after minting liquidity to a position from IUniswapV3Pool#mint.

*liqiuidity is allways in range so we don't need to check if amount0 or amount1 is 0*


```solidity
function uniswapV3MintCallback(uint256 amount0Owed, uint256 amount1Owed, bytes calldata data) external override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount0Owed`|`uint256`|The amount of token0 due to the pool for the minted liquidity|
|`amount1Owed`|`uint256`|The amount of token1 due to the pool for the minted liquidity|
|`data`|`bytes`|Any data passed through by the caller via the IUniswapV3PoolActions#mint call|


### _addLiquidity

Add liquidity to an initialized pool


```solidity
function _addLiquidity(AddLiquidityParams memory params) internal returns (uint256 amount0, uint256 amount1);
```

## Structs
### AddLiquidityParams

```solidity
struct AddLiquidityParams {
    IUniswapV3Pool pool;
    uint128 liquidity;
}
```

