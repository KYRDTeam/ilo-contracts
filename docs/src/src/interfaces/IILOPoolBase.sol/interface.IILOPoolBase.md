# IILOPoolBase
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/ae631fe4bfbce302e21cc5e317f651168c939703/src/interfaces/IILOPoolBase.sol)

**Inherits:**
IERC721Metadata, IERC721Enumerable, [IILOVest](/src/interfaces/IILOVest.sol/interface.IILOVest.md), [IILOPoolImmutableState](/src/interfaces/IILOPoolImmutableState.sol/interface.IILOPoolImmutableState.md)

Wraps Uniswap V3 positions in a non-fungible token interface which allows for them to be transferred
and authorized.


## Functions
### claim

Returns number of collected tokens associated with a given token ID.


```solidity
function claim(uint256 tokenId) external returns (uint256 amount0, uint256 amount1);
```

### launch


```solidity
function launch(address uniV3PoolAddress, PoolAddress.PoolKey calldata poolKey, uint160 sqrtPriceX96) external;
```

### cancel


```solidity
function cancel() external;
```

### CANCELLED


```solidity
function CANCELLED() external view returns (bool);
```

### positions


```solidity
function positions(uint256 tokenId) external view returns (Position memory);
```

### totalInititalLiquidity


```solidity
function totalInititalLiquidity() external view returns (uint128);
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

### Claim

```solidity
event Claim(
    address indexed user,
    uint256 tokenId,
    uint128 liquidity,
    uint256 amount0WithFee,
    uint256 amount1WithFee,
    uint256 feeGrowthInside0LastX128,
    uint256 feeGrowthInside1LastX128,
    uint256 fee0Claimed,
    uint256 fee1Claimed
);
```

### Buy

```solidity
event Buy(address indexed investor, uint256 tokenId, uint256 raiseAmount);
```

### PoolLaunch

```solidity
event PoolLaunch(address indexed project, uint128 liquidity, uint256 token0, uint256 token1);
```

### PoolCancelled

```solidity
event PoolCancelled();
```

### Refund

```solidity
event Refund(address indexed owner, uint256 tokenId, uint256 refundAmount);
```

### ProjectRefund

```solidity
event ProjectRefund(address indexed projectAdmin, uint256 saleTokenAmount);
```

## Structs
### Position

```solidity
struct Position {
    uint128 liquidity;
    uint256 feeGrowthInside0LastX128;
    uint256 feeGrowthInside1LastX128;
    uint256 raiseAmount;
}
```

### InitPoolBaseParams

```solidity
struct InitPoolBaseParams {
    string projectId;
    uint256 tokenAmount;
    int24 tickLower;
    int24 tickUpper;
}
```

### InitPoolParams

```solidity
struct InitPoolParams {
    InitPoolBaseParams baseParams;
    IILOVest.VestingConfig[] vestingConfigs;
}
```

