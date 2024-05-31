# LiquidityAmounts
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/c821b671bb5c9be46c122173f3f384ce7950f2da/src/libraries/LiquidityAmounts.sol)

Provides functions for computing liquidity amounts from token amounts and prices


## Functions
### toUint128

Downcasts uint256 to uint128


```solidity
function toUint128(uint256 x) private pure returns (uint128 y);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`x`|`uint256`|The uint258 to be downcasted|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`y`|`uint128`|The passed value, downcasted to uint128|


### getLiquidityForAmount0

Computes the amount of liquidity received for a given amount of token0 and price range

*Calculates amount0 * (sqrt(upper) * sqrt(lower)) / (sqrt(upper) - sqrt(lower))*


```solidity
function getLiquidityForAmount0(uint160 sqrtRatioAX96, uint160 sqrtRatioBX96, uint256 amount0)
    internal
    pure
    returns (uint128 liquidity);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sqrtRatioAX96`|`uint160`|A sqrt price representing the first tick boundary|
|`sqrtRatioBX96`|`uint160`|A sqrt price representing the second tick boundary|
|`amount0`|`uint256`|The amount0 being sent in|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`liquidity`|`uint128`|The amount of returned liquidity|


### getLiquidityForAmount1

Computes the amount of liquidity received for a given amount of token1 and price range

*Calculates amount1 / (sqrt(upper) - sqrt(lower)).*


```solidity
function getLiquidityForAmount1(uint160 sqrtRatioAX96, uint160 sqrtRatioBX96, uint256 amount1)
    internal
    pure
    returns (uint128 liquidity);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sqrtRatioAX96`|`uint160`|A sqrt price representing the first tick boundary|
|`sqrtRatioBX96`|`uint160`|A sqrt price representing the second tick boundary|
|`amount1`|`uint256`|The amount1 being sent in|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`liquidity`|`uint128`|The amount of returned liquidity|


### getLiquidityForAmounts

Computes the maximum amount of liquidity received for a given amount of token0, token1, the current
pool prices and the prices at the tick boundaries


```solidity
function getLiquidityForAmounts(
    uint160 sqrtRatioX96,
    uint160 sqrtRatioAX96,
    uint160 sqrtRatioBX96,
    uint256 amount0,
    uint256 amount1
) internal pure returns (uint128 liquidity);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sqrtRatioX96`|`uint160`|A sqrt price representing the current pool prices|
|`sqrtRatioAX96`|`uint160`|A sqrt price representing the first tick boundary|
|`sqrtRatioBX96`|`uint160`|A sqrt price representing the second tick boundary|
|`amount0`|`uint256`|The amount of token0 being sent in|
|`amount1`|`uint256`|The amount of token1 being sent in|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`liquidity`|`uint128`|The maximum amount of liquidity received|


### getAmount0ForLiquidity

Computes the amount of token0 for a given amount of liquidity and a price range


```solidity
function getAmount0ForLiquidity(uint160 sqrtRatioAX96, uint160 sqrtRatioBX96, uint128 liquidity)
    internal
    pure
    returns (uint256 amount0);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sqrtRatioAX96`|`uint160`|A sqrt price representing the first tick boundary|
|`sqrtRatioBX96`|`uint160`|A sqrt price representing the second tick boundary|
|`liquidity`|`uint128`|The liquidity being valued|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`amount0`|`uint256`|The amount of token0|


### getAmount1ForLiquidity

Computes the amount of token1 for a given amount of liquidity and a price range


```solidity
function getAmount1ForLiquidity(uint160 sqrtRatioAX96, uint160 sqrtRatioBX96, uint128 liquidity)
    internal
    pure
    returns (uint256 amount1);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sqrtRatioAX96`|`uint160`|A sqrt price representing the first tick boundary|
|`sqrtRatioBX96`|`uint160`|A sqrt price representing the second tick boundary|
|`liquidity`|`uint128`|The liquidity being valued|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`amount1`|`uint256`|The amount of token1|


### getAmountsForLiquidity

Computes the token0 and token1 value for a given amount of liquidity, the current
pool prices and the prices at the tick boundaries


```solidity
function getAmountsForLiquidity(uint160 sqrtRatioX96, uint160 sqrtRatioAX96, uint160 sqrtRatioBX96, uint128 liquidity)
    internal
    pure
    returns (uint256 amount0, uint256 amount1);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sqrtRatioX96`|`uint160`|A sqrt price representing the current pool prices|
|`sqrtRatioAX96`|`uint160`|A sqrt price representing the first tick boundary|
|`sqrtRatioBX96`|`uint160`|A sqrt price representing the second tick boundary|
|`liquidity`|`uint128`|The liquidity being valued|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`amount0`|`uint256`|The amount of token0|
|`amount1`|`uint256`|The amount of token1|


### getInrangeAmount0ForAmount1


```solidity
function getInrangeAmount0ForAmount1(
    uint160 sqrtRatioX96,
    uint160 sqrtRatioAX96,
    uint160 sqrtRatioBX96,
    uint256 amount1,
    bool roundUp
) internal pure returns (uint256);
```

### getInrangeAmount1ForAmount0


```solidity
function getInrangeAmount1ForAmount0(
    uint160 sqrtRatioX96,
    uint160 sqrtRatioAX96,
    uint160 sqrtRatioBX96,
    uint256 amount0,
    bool roundUp
) internal pure returns (uint256);
```

