# ILOPool
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/1de4d92cce6f0722e8736db455733703c706f30f/src/ILOPool.sol)

**Inherits:**
ERC721, [IILOPool](/src/interfaces/IILOPool.sol/interface.IILOPool.md), [ILOWhitelist](/src/base/ILOWhitelist.sol/abstract.ILOWhitelist.md), [ILOSale](/src/base/ILOSale.sol/abstract.ILOSale.md), [ILOVest](/src/base/ILOVest.sol/abstract.ILOVest.md), [Initializable](/src/base/Initializable.sol/abstract.Initializable.md), [Multicall](/src/base/Multicall.sol/abstract.Multicall.md), [ILOPoolImmutableState](/src/base/ILOPoolImmutableState.sol/abstract.ILOPoolImmutableState.md), [PoolInitializer](/src/base/PoolInitializer.sol/abstract.PoolInitializer.md), [LiquidityManagement](/src/base/LiquidityManagement.sol/abstract.LiquidityManagement.md), [PeripheryValidation](/src/base/PeripheryValidation.sol/abstract.PeripheryValidation.md)

Wraps Uniswap V3 positions in the ERC721 non-fungible token interface


## State Variables
### investorVestConfigs

```solidity
LinearVest[] investorVestConfigs;
```


### _positions
*The token ID position data*


```solidity
mapping(uint256 => Position) private _positions;
```


### _nextId
*The ID of the next token that will be minted. Skips 0*


```solidity
uint256 private _nextId = 1;
```


### totalRaised

```solidity
uint256 totalRaised;
```


## Functions
### constructor


```solidity
constructor(address _factory, address _WETH9)
    ERC721("KRYSTAL ILOPool V1", "KYRSTAL-ILO-V1")
    ILOPoolImmutableState(_factory, _WETH9);
```

### initialize


```solidity
function initialize(InitPoolParams calldata params) external override whenNotInitialized;
```

### positions

Returns the position information associated with a given token ID.

*Throws if the token ID is not valid.*


```solidity
function positions(uint256 tokenId)
    external
    view
    override
    returns (
        address token0,
        address token1,
        uint24 fee,
        int24 tickLower,
        int24 tickUpper,
        uint128 liquidity,
        uint256 feeGrowthInside0LastX128,
        uint256 feeGrowthInside1LastX128,
        uint128 tokensOwed0,
        uint128 tokensOwed1
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
|`tokensOwed0`|`uint128`|The uncollected amount of token0 owed to the position as of the last computation|
|`tokensOwed1`|`uint128`|The uncollected amount of token1 owed to the position as of the last computation|


### buy


```solidity
function buy(BuyParams calldata params)
    external
    override
    duringSale
    onlyWhitelisted(params.recipient)
    returns (uint256 tokenId, uint128 liquidityDelta, uint256 amountAdded0, uint256 amountAdded1);
```

### isAuthorizedForToken


```solidity
modifier isAuthorizedForToken(uint256 tokenId);
```

### decreaseLiquidity

Decreases the amount of liquidity in a position and accounts it to the position


```solidity
function decreaseLiquidity(DecreaseLiquidityParams calldata params)
    external
    payable
    override
    isAuthorizedForToken(params.tokenId)
    afterSale
    checkDeadline(params.deadline)
    returns (uint256 amount0, uint256 amount1);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`params`|`DecreaseLiquidityParams`|tokenId The ID of the token for which liquidity is being decreased, amount The amount by which liquidity will be decreased, amount0Min The minimum amount of token0 that should be accounted for the burned liquidity, amount1Min The minimum amount of token1 that should be accounted for the burned liquidity, deadline The time by which the transaction must be included to effect the change|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`amount0`|`uint256`|The amount of token0 accounted to the position's tokens owed|
|`amount1`|`uint256`|The amount of token1 accounted to the position's tokens owed|


### collect

Collects up to a maximum amount of fees owed to a specific position to the recipient


```solidity
function collect(CollectParams calldata params)
    external
    payable
    override
    isAuthorizedForToken(params.tokenId)
    returns (uint256 amount0, uint256 amount1);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`params`|`CollectParams`|tokenId The ID of the NFT for which tokens are being collected, recipient The account that should receive the tokens, amount0Max The maximum amount of token0 to collect, amount1Max The maximum amount of token1 to collect|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`amount0`|`uint256`|The amount of fees collected in token0|
|`amount1`|`uint256`|The amount of fees collected in token1|


### burn

Burns a token ID, which deletes it from the NFT contract. The token must have 0 liquidity and all tokens
must be collected first.


```solidity
function burn(uint256 tokenId) external payable override isAuthorizedForToken(tokenId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|The ID of the token that is being burned|


### launch


```solidity
function launch() external override afterSale;
```

### totalSold


```solidity
function totalSold() public view returns (uint256);
```

### _saleAmountNeeded


```solidity
function _saleAmountNeeded(uint256 raiseAmount) internal view returns (uint256);
```

### _unlockedLiquidity


```solidity
function _unlockedLiquidity(uint256 tokenId) internal view override returns (uint128 unlockedLiquidity);
```

### _assignVestingSchedule


```solidity
function _assignVestingSchedule(uint256 nftId, LinearVest[] storage vestingSchedule) internal;
```

### _updateVestingLiquidity


```solidity
function _updateVestingLiquidity(uint256 nftId, uint128 liquidity) internal;
```

## Structs
### Position

```solidity
struct Position {
    uint128 liquidity;
    uint256 feeGrowthInside0LastX128;
    uint256 feeGrowthInside1LastX128;
    uint128 tokensOwed0;
    uint128 tokensOwed1;
}
```

