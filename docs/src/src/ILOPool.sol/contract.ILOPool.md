# ILOPool
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/ae631fe4bfbce302e21cc5e317f651168c939703/src/ILOPool.sol)

**Inherits:**
[ILOPoolBase](/src/base/ILOPoolBase.sol/abstract.ILOPoolBase.md), [IILOPool](/src/interfaces/IILOPool.sol/interface.IILOPool.md)

Wraps Uniswap V3 positions in the ERC721 non-fungible token interface


## State Variables
### _vestingConfigs

```solidity
VestingConfig[] private _vestingConfigs;
```


## Functions
### initialize


```solidity
function initialize(InitPoolParams calldata params) external override;
```

### launch


```solidity
function launch(address uniV3PoolAddress, PoolAddress.PoolKey calldata poolKey, uint160 sqrtPriceX96)
    external
    override
    onlyManager
    onlyInitializedProject;
```

### claim

Returns number of collected tokens associated with a given token ID.


```solidity
function claim(uint256 tokenId) external override returns (uint256 amount0, uint256 amount1);
```

### cancel


```solidity
function cancel() external override onlyManager;
```

### name


```solidity
function name() public pure override returns (string memory);
```

### symbol


```solidity
function symbol() public pure override returns (string memory);
```

### _initImplementation


```solidity
function _initImplementation() internal override;
```

