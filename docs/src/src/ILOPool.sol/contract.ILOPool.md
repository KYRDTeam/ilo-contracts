# ILOPool
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/a3fc4c57db039cc1b79c7925531b021576d1b1a7/src/ILOPool.sol)

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
constructor() ERC721("KYRSTAL ILOPool V1", "KYRSTAL-ILO-V1");
```

### name


```solidity
function name() public view override(ERC721, IERC721Metadata) returns (string memory);
```

### symbol


```solidity
function symbol() public view override(ERC721, IERC721Metadata) returns (string memory);
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
function buy(uint256 raiseAmount, address recipient)
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

### _deductFees


```solidity
function _deductFees(uint256 amount0, uint256 amount1, uint16 feeBPS)
    internal
    pure
    returns (uint256 amount0Left, uint256 amount1Left);
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

