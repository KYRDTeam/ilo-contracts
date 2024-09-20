# ILOPoolSale
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/af88dd9b3e8283ab97b6c9511aeb7bb607e3649d/src/ILOPoolSale.sol)

**Inherits:**
[ILOPoolBase](/src/base/ILOPoolBase.sol/abstract.ILOPoolBase.md), [IILOPoolSale](/src/interfaces/IILOPoolSale.sol/interface.IILOPoolSale.md), [ILOWhitelist](/src/base/ILOWhitelist.sol/abstract.ILOWhitelist.md), ReentrancyGuard


## State Variables
### SALE_START

```solidity
uint64 public override SALE_START;
```


### SALE_END

```solidity
uint64 public override SALE_END;
```


### MIN_RAISE

```solidity
uint256 public override MIN_RAISE;
```


### MAX_RAISE

```solidity
uint256 public override MAX_RAISE;
```


### TOTAL_RAISED

```solidity
uint256 public override TOTAL_RAISED;
```


### _vestingSchedule

```solidity
LinearVest[] private _vestingSchedule;
```


## Functions
### onlyProjectAdmin


```solidity
modifier onlyProjectAdmin() override;
```

### duringSale


```solidity
modifier duringSale();
```

### beforeSale


```solidity
modifier beforeSale();
```

### afterSale


```solidity
modifier afterSale();
```

### initialize


```solidity
function initialize(InitParams calldata params) external override;
```

### buy


```solidity
function buy(uint256 raiseAmount, address recipient)
    external
    override
    duringSale
    whenNotCancelled
    nonReentrant
    returns (uint256 tokenId);
```

### launch


```solidity
function launch(address uniV3PoolAddress, PoolAddress.PoolKey calldata poolKey, uint160 sqrtPriceX96)
    external
    override
    onlyManager
    onlyInitializedProject
    whenNotCancelled
    afterSale;
```

### claim


```solidity
function claim(uint256 tokenId) external override afterLaunch nonReentrant returns (uint256 amount0, uint256 amount1);
```

### cancel


```solidity
function cancel() external override onlyManager beforeSale;
```

### claimRefund


```solidity
function claimRefund(uint256 tokenId)
    external
    override
    isAuthorizedForToken(tokenId)
    nonReentrant
    returns (uint256 refundAmount);
```

### refundable


```solidity
function refundable() external view override returns (bool);
```

### tokenSoldAmount


```solidity
function tokenSoldAmount() public view override returns (uint256);
```

### _initImplementation


```solidity
function _initImplementation() internal override;
```

### _onPoolSaleFail


```solidity
function _onPoolSaleFail() internal;
```

### _refundable


```solidity
function _refundable() internal view returns (bool);
```

### _beforeTokenTransfer

*Hook that is called before any token transfer. This includes minting
and burning.
Calling conditions:
- When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
transferred to `to`.
- When `from` is zero, `tokenId` will be minted for `to`.
- When `to` is zero, ``from``'s `tokenId` will be burned.
- `from` cannot be the zero address.
- `to` cannot be the zero address.
To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].*


```solidity
function _beforeTokenTransfer(address from, address, uint256) internal view override;
```

### _fillLiquidityForPosition


```solidity
function _fillLiquidityForPosition(uint256 tokenId) private;
```

