# LiquidityManagement
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/a3fc4c57db039cc1b79c7925531b021576d1b1a7/src/base/LiquidityManagement.sol)

**Inherits:**
IUniswapV3MintCallback, [ILOPoolImmutableState](/src/base/ILOPoolImmutableState.sol/abstract.ILOPoolImmutableState.md), [PeripheryPayments](/src/base/PeripheryPayments.sol/abstract.PeripheryPayments.md)

Internal functions for safely managing liquidity in Uniswap V3


## Functions
### uniswapV3MintCallback

Called to `msg.sender` after minting liquidity to a position from IUniswapV3Pool#mint.

*In the implementation you must pay the pool tokens owed for the minted liquidity.
The caller of this method must be checked to be a UniswapV3Pool deployed by the canonical UniswapV3Factory.*


```solidity
function uniswapV3MintCallback(uint256 amount0Owed, uint256 amount1Owed, bytes calldata data) external override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount0Owed`|`uint256`|The amount of token0 due to the pool for the minted liquidity|
|`amount1Owed`|`uint256`|The amount of token1 due to the pool for the minted liquidity|
|`data`|`bytes`|Any data passed through by the caller via the IUniswapV3PoolActions#mint call|


### addLiquidity

Add liquidity to an initialized pool


```solidity
function addLiquidity(AddLiquidityParams memory params)
    internal
    returns (uint128 liquidity, uint256 amount0, uint256 amount1, IUniswapV3Pool pool);
```

## Structs
### MintCallbackData

```solidity
struct MintCallbackData {
    PoolAddress.PoolKey poolKey;
    address payer;
}
```

### AddLiquidityParams

```solidity
struct AddLiquidityParams {
    address token0;
    address token1;
    uint24 fee;
    address recipient;
    int24 tickLower;
    int24 tickUpper;
    uint256 amount0Desired;
    uint256 amount1Desired;
    uint256 amount0Min;
    uint256 amount1Min;
}
```

