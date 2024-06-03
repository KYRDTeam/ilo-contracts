# ILOPool
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/319686becad627d36fa714d2345ca75a5a55cab1/src/ILOPool.sol)

**Inherits:**
ERC721, [IILOPool](/src/interfaces/IILOPool.sol/interface.IILOPool.md), [ILOWhitelist](/src/base/ILOWhitelist.sol/abstract.ILOWhitelist.md), [ILOSale](/src/base/ILOSale.sol/abstract.ILOSale.md), [ILOVest](/src/base/ILOVest.sol/abstract.ILOVest.md), [Initializable](/src/base/Initializable.sol/abstract.Initializable.md), [Multicall](/src/base/Multicall.sol/abstract.Multicall.md), [ILOPoolImmutableState](/src/base/ILOPoolImmutableState.sol/abstract.ILOPoolImmutableState.md), [LiquidityManagement](/src/base/LiquidityManagement.sol/abstract.LiquidityManagement.md), [PeripheryValidation](/src/base/PeripheryValidation.sol/abstract.PeripheryValidation.md)

Wraps Uniswap V3 positions in the ERC721 non-fungible token interface


## State Variables
### _launchSucceeded
*when lauch successfully we can not refund anymore*


```solidity
bool private _launchSucceeded;
```


### _refundTriggered
*when refund triggered, we can not launch anymore*


```solidity
bool private _refundTriggered;
```


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
constructor() ERC721("KRYSTAL ILOPool V1", "KRYSTAL-ILO-V1");
```

### name


```solidity
function name() public pure override(ERC721, IERC721Metadata) returns (string memory);
```

### symbol


```solidity
function symbol() public pure override(ERC721, IERC721Metadata) returns (string memory);
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


### buy


```solidity
function buy(address payer, uint256 raiseAmount, address recipient)
    external
    override
    duringSale
    onlyWhitelisted(recipient)
    returns (uint256 tokenId, uint128 liquidityDelta, uint256 amountAdded0, uint256 amountAdded1);
```

### isAuthorizedForToken


```solidity
modifier isAuthorizedForToken(uint256 tokenId);
```

### claim

Returns number of collected tokens associated with a given token ID.


```solidity
function claim(uint256 tokenId)
    external
    payable
    override
    isAuthorizedForToken(tokenId)
    afterSale
    returns (uint256 amount0, uint256 amount1);
```

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

### claimRefund


```solidity
function claimRefund(uint256 tokenId) external isAuthorizedForToken(tokenId);
```

### totalSold

returns amount of sale token that has already been sold


```solidity
function totalSold() public view returns (uint256);
```

### _saleAmountNeeded

return sale token amount needed for the raiseAmount.

*sale token amount is rounded up*


```solidity
function _saleAmountNeeded(uint256 raiseAmount) internal view returns (uint256);
```

### _unlockedLiquidity

calculate amount of liquidity unlocked for claim


```solidity
function _unlockedLiquidity(uint256 tokenId) internal view override returns (uint128 unlockedLiquidity);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|nft token id of position|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`unlockedLiquidity`|`uint128`|amount of unlocked liquidity|


### _assignVestingSchedule

assign vesting schedule for position


```solidity
function _assignVestingSchedule(uint256 nftId, LinearVest[] storage vestingSchedule) internal;
```

### _updateVestingLiquidity

update total liquidity for vesting position
vesting liquidity of position only changes when investor buy ilo


```solidity
function _updateVestingLiquidity(uint256 nftId, uint128 liquidity) internal;
```

### _deductFees

calculate the amount left after deduct fee


```solidity
function _deductFees(uint256 amount0, uint256 amount1, uint16 feeBPS)
    internal
    pure
    returns (uint256 amount0Left, uint256 amount1Left);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount0`|`uint256`|the amount of token0 before deduct fee|
|`amount1`|`uint256`|the amount of token1 before deduct fee|
|`feeBPS`|`uint16`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`amount0Left`|`uint256`|the amount of token0 after deduct fee|
|`amount1Left`|`uint256`|the amount of token1 after deduct fee|


### _claimableLiquidity


```solidity
function _claimableLiquidity(uint256 tokenId) internal view override returns (uint128 claimableLiquidity);
```

## Events
### Claim

```solidity
event Claim(address indexed user, uint128 liquidity, uint256 amount0, uint256 amount1);
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

