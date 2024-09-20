# OracleLibrary
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/af88dd9b3e8283ab97b6c9511aeb7bb607e3649d/src/libraries/OracleLibrary.sol)

Provides functions to integrate with V3 pool oracle


## Functions
### consult

Fetches time-weighted average tick using Uniswap V3 oracle


```solidity
function consult(address pool, uint32 period) internal view returns (int24 timeWeightedAverageTick);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`pool`|`address`|Address of Uniswap V3 pool that we want to observe|
|`period`|`uint32`|Number of seconds in the past to start calculating time-weighted average|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`timeWeightedAverageTick`|`int24`|The time-weighted average tick from (block.timestamp - period) to block.timestamp|


### getQuoteAtTick

Given a tick and a token amount, calculates the amount of token received in exchange


```solidity
function getQuoteAtTick(int24 tick, uint128 baseAmount, address baseToken, address quoteToken)
    internal
    pure
    returns (uint256 quoteAmount);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tick`|`int24`|Tick value used to calculate the quote|
|`baseAmount`|`uint128`|Amount of token to be converted|
|`baseToken`|`address`|Address of an ERC20 token contract used as the baseAmount denomination|
|`quoteToken`|`address`|Address of an ERC20 token contract used as the quoteAmount denomination|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`quoteAmount`|`uint256`|Amount of quoteToken received for baseAmount of baseToken|


### getOldestObservationSecondsAgo

Given a pool, it returns the number of seconds ago of the oldest stored observation


```solidity
function getOldestObservationSecondsAgo(address pool) internal view returns (uint32 secondsAgo);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`pool`|`address`|Address of Uniswap V3 pool that we want to observe|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`secondsAgo`|`uint32`|The number of seconds ago of the oldest observation stored for the pool|


