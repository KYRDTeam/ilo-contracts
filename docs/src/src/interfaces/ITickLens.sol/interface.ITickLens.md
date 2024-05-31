# ITickLens
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/c821b671bb5c9be46c122173f3f384ce7950f2da/src/interfaces/ITickLens.sol)

Provides functions for fetching chunks of tick data for a pool

*This avoids the waterfall of fetching the tick bitmap, parsing the bitmap to know which ticks to fetch, and
then sending additional multicalls to fetch the tick data*


## Functions
### getPopulatedTicksInWord

Get all the tick data for the populated ticks from a word of the tick bitmap of a pool


```solidity
function getPopulatedTicksInWord(address pool, int16 tickBitmapIndex)
    external
    view
    returns (PopulatedTick[] memory populatedTicks);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`pool`|`address`|The address of the pool for which to fetch populated tick data|
|`tickBitmapIndex`|`int16`|The index of the word in the tick bitmap for which to parse the bitmap and fetch all the populated ticks|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`populatedTicks`|`PopulatedTick[]`|An array of tick data for the given word in the tick bitmap|


## Structs
### PopulatedTick

```solidity
struct PopulatedTick {
    int24 tick;
    int128 liquidityNet;
    uint128 liquidityGross;
}
```

