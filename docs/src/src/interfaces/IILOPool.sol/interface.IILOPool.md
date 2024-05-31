# IILOPool
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/c821b671bb5c9be46c122173f3f384ce7950f2da/src/interfaces/IILOPool.sol)

**Inherits:**
[IILOConfig](/src/interfaces/IILOConfig.sol/interface.IILOConfig.md), [IPeripheryPayments](/src/interfaces/IPeripheryPayments.sol/interface.IPeripheryPayments.md), [IILOPoolImmutableState](/src/interfaces/IILOPoolImmutableState.sol/interface.IILOPoolImmutableState.md), IERC721Metadata, IERC721Enumerable

Wraps Uniswap V3 positions in a non-fungible token interface which allows for them to be transferred
and authorized.


## Functions
### positions

Returns the position information associated with a given token ID.

*Throws if the token ID is not valid.*


```solidity
function positions(uint256 tokenId)
    external
    view
    returns (
        address token0,
        address token1,
        uint24 fee,
        int24 tickLower,
        int24 tickUpper,
        uint128 liquidity,
        uint256 feeGrowthInside0LastX128,
        uint256 feeGrowthInside1LastX128
    );
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|The ID of the token that represents the position|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`token0`|`address`|The address of the token0 for a specific pool|
|`token1`|`address`|The address of the token1 for a specific pool|
|`fee`|`uint24`|The fee associated with the pool|
|`tickLower`|`int24`|The lower end of the tick range for the position|
|`tickUpper`|`int24`|The higher end of the tick range for the position|
|`liquidity`|`uint128`|The liquidity of the position|
|`feeGrowthInside0LastX128`|`uint256`|The fee growth of token0 as of the last action on the individual position|
|`feeGrowthInside1LastX128`|`uint256`|The fee growth of token1 as of the last action on the individual position|


### claim

Returns number of collected tokens associated with a given token ID.


```solidity
function claim(uint256 tokenId) external payable returns (uint256 amount0, uint256 amount1);
```

### burn

Burns a token ID, which deletes it from the NFT contract. The token must have 0 liquidity and all tokens
must be collected first.


```solidity
function burn(uint256 tokenId) external payable;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|The ID of the token that is being burned|


### initialize


```solidity
function initialize(InitPoolParams calldata initPoolParams) external;
```

### launch


```solidity
function launch() external;
```

## Events
### IncreaseLiquidity
Emitted when liquidity is increased for a position NFT

*Also emitted when a token is minted*


```solidity
event IncreaseLiquidity(uint256 indexed tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|The ID of the token for which liquidity was increased|
|`liquidity`|`uint128`|The amount by which liquidity for the NFT position was increased|
|`amount0`|`uint256`|The amount of token0 that was paid for the increase in liquidity|
|`amount1`|`uint256`|The amount of token1 that was paid for the increase in liquidity|

### DecreaseLiquidity
Emitted when liquidity is decreased for a position NFT


```solidity
event DecreaseLiquidity(uint256 indexed tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|The ID of the token for which liquidity was decreased|
|`liquidity`|`uint128`|The amount by which liquidity for the NFT position was decreased|
|`amount0`|`uint256`|The amount of token0 that was accounted for the decrease in liquidity|
|`amount1`|`uint256`|The amount of token1 that was accounted for the decrease in liquidity|

### Collect
Emitted when tokens are collected for a position NFT

*The amounts reported may not be exactly equivalent to the amounts transferred, due to rounding behavior*


```solidity
event Collect(uint256 indexed tokenId, address recipient, uint256 amount0, uint256 amount1);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|The ID of the token for which underlying tokens were collected|
|`recipient`|`address`|The address of the account that received the collected tokens|
|`amount0`|`uint256`|The amount of token0 owed to the position that was collected|
|`amount1`|`uint256`|The amount of token1 owed to the position that was collected|

### ILOPoolInitialized

```solidity
event ILOPoolInitialized(
    address indexed univ3Pool,
    int32 tickLower,
    int32 tickUpper,
    uint16 platformFee,
    uint16 performanceFee,
    uint16 investorShares,
    IILOSale.SaleInfo saleInfo
);
```

