# ILOPoolBase
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/e40a6cd6fab3cc84638afa793f4d9e791b183158/src/base/ILOPoolBase.sol)

**Inherits:**
[IILOPoolBase](/src/interfaces/IILOPoolBase.sol/interface.IILOPoolBase.md), ERC721, [ILOVest](/src/base/ILOVest.sol/abstract.ILOVest.md), [ILOPoolImmutableState](/src/base/ILOPoolImmutableState.sol/abstract.ILOPoolImmutableState.md), [Initializable](/src/base/Initializable.sol/abstract.Initializable.md), Multicall, [LiquidityManagement](/src/base/LiquidityManagement.sol/abstract.LiquidityManagement.md)

Wraps Uniswap V3 positions in the ERC721 non-fungible token interface


## State Variables
### CANCELLED

```solidity
bool public override CANCELLED;
```


### _positions
*The token ID position data*


```solidity
mapping(uint256 => Position) internal _positions;
```


### _nextId
*The ID of the next token that will be minted. Skips 0*


```solidity
uint256 internal _nextId;
```


### _tokenAmount

```solidity
uint256 internal _tokenAmount;
```


### _totalInitialLiquidity

```solidity
uint128 internal _totalInitialLiquidity;
```


## Functions
### onlyInitializedProject


```solidity
modifier onlyInitializedProject();
```

### isAuthorizedForToken


```solidity
modifier isAuthorizedForToken(uint256 tokenId);
```

### onlyManager


```solidity
modifier onlyManager();
```

### afterLaunch


```solidity
modifier afterLaunch();
```

### whenNotCancelled


```solidity
modifier whenNotCancelled();
```

### constructor


```solidity
constructor() ERC721("", "");
```

### burn


```solidity
function burn(uint256 tokenId) external isAuthorizedForToken(tokenId);
```

### positions


```solidity
function positions(uint256 tokenId) external view override returns (Position memory);
```

### totalInititalLiquidity


```solidity
function totalInititalLiquidity() external view override returns (uint128 liquidity);
```

### _claim


```solidity
function _claim(uint256 tokenId)
    internal
    isAuthorizedForToken(tokenId)
    afterLaunch
    returns (uint256 amount0, uint256 amount1);
```

### _burn

*Destroys `tokenId`.
The approval is cleared when the token is burned.
Requirements:
- `tokenId` must exist.
Emits a {Transfer} event.*


```solidity
function _burn(uint256 tokenId) internal override;
```

### _initialize


```solidity
function _initialize(InitPoolBaseParams calldata params) internal whenNotInitialized;
```

### _launchLiquidity


```solidity
function _launchLiquidity(
    address uniV3PoolAddress,
    PoolAddress.PoolKey calldata poolKey,
    uint160 sqrtPriceX96,
    uint256 tokenAmount
) internal returns (uint128 liquidity);
```

### _cancel


```solidity
function _cancel() internal whenNotCancelled;
```

### _unlockedLiquidity

calculate amount of liquidity unlocked for claim


```solidity
function _unlockedLiquidity(uint128 totalLiquidity, LinearVest[] storage vestingSchedule)
    internal
    view
    returns (uint128 liquidityUnlocked);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`totalLiquidity`|`uint128`|total liquidity to vest|
|`vestingSchedule`|`LinearVest[]`|the vesting schedule|


### _claimableLiquidity


```solidity
function _claimableLiquidity(uint256 tokenId) internal view returns (uint128);
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


