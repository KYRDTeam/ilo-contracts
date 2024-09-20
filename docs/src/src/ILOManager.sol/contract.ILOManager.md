# ILOManager
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/af88dd9b3e8283ab97b6c9511aeb7bb607e3649d/src/ILOManager.sol)

**Inherits:**
[IILOManager](/src/interfaces/IILOManager.sol/interface.IILOManager.md), Ownable, [Initializable](/src/base/Initializable.sol/abstract.Initializable.md)


## State Variables
### UNIV3_FACTORY

```solidity
address public override UNIV3_FACTORY;
```


### TOKEN_FACTORY

```solidity
address public override TOKEN_FACTORY;
```


### PLATFORM_FEE

```solidity
uint16 public override PLATFORM_FEE;
```


### PERFORMANCE_FEE

```solidity
uint16 public override PERFORMANCE_FEE;
```


### FEE_TAKER

```solidity
address public override FEE_TAKER;
```


### ILO_POOL_IMPLEMENTATION

```solidity
address public override ILO_POOL_IMPLEMENTATION;
```


### ILO_POOL_SALE_IMPLEMENTATION

```solidity
address public override ILO_POOL_SALE_IMPLEMENTATION;
```


### INIT_PROJECT_FEE

```solidity
uint256 public override INIT_PROJECT_FEE;
```


### _projects

```solidity
mapping(string => Project) private _projects;
```


### _initializedILOPools

```solidity
mapping(string => EnumerableSet.AddressSet) private _initializedILOPools;
```


## Functions
### onlyProjectAdmin


```solidity
modifier onlyProjectAdmin(string calldata projectId);
```

### onlyInitializedPool


```solidity
modifier onlyInitializedPool(string calldata projectId);
```

### onlyInitializedProject


```solidity
modifier onlyInitializedProject(string calldata projectId);
```

### ownerOrProjectAdmin


```solidity
modifier ownerOrProjectAdmin(string calldata projectId);
```

### constructor

*since deploy via deployer so we need to claim ownership*


```solidity
constructor();
```

### initialize


```solidity
function initialize(
    address initialOwner,
    address _feeTaker,
    address iloPoolImplementation,
    address iloPoolSaleImplementation,
    address uniV3Factory,
    address tokenFactory,
    uint256 createProjectFee,
    uint16 platformFee,
    uint16 performanceFee
) external override whenNotInitialized;
```

### initProject

init project with details


```solidity
function initProject(InitProjectParams calldata params) external payable override afterInitialize;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`params`|`InitProjectParams`|the parameters to initialize the project|


### initILOPool

this function init an `ILO Pool` which will be used for sale and vest. One project can init many ILO Pool


```solidity
function initILOPool(IILOPoolBase.InitPoolParams calldata params)
    external
    override
    onlyProjectAdmin(params.baseParams.projectId)
    onlyInitializedProject(params.baseParams.projectId)
    returns (address poolAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`params`|`IILOPoolBase.InitPoolParams`|the parameters for init project|


### initILOPoolSale


```solidity
function initILOPoolSale(IILOPoolSale.InitParams calldata params)
    external
    override
    onlyProjectAdmin(params.baseParams.projectId)
    onlyInitializedProject(params.baseParams.projectId)
    returns (address poolAddress);
```

### onPoolSaleFail


```solidity
function onPoolSaleFail(string calldata projectId) external override onlyInitializedPool(projectId);
```

### iloPoolLaunchCallback

this function takes params from ILOPools
and transfer token directly to uniswap v3 pool
without temparory holding in ILOPool


```solidity
function iloPoolLaunchCallback(
    string calldata projectId,
    address token0,
    uint256 amount0,
    address token1,
    uint256 amount1,
    address uniswapV3Pool
) external override onlyInitializedPool(projectId);
```

### setPlatformFee

set platform fee for decrease liquidity. Platform fee is imutable among all project's pools


```solidity
function setPlatformFee(uint16 _platformFee) external override onlyOwner;
```

### setPerformanceFee

set platform fee for decrease liquidity. Platform fee is imutable among all project's pools


```solidity
function setPerformanceFee(uint16 _performanceFee) external override onlyOwner;
```

### setFeeTaker

set platform fee for decrease liquidity. Platform fee is imutable among all project's pools


```solidity
function setFeeTaker(address _feeTaker) external override onlyOwner;
```

### setILOPoolImplementation


```solidity
function setILOPoolImplementation(address iloPoolImplementation) external override onlyOwner;
```

### setTokenFactory


```solidity
function setTokenFactory(address _tokenFactory) external override onlyOwner;
```

### transferAdminProject


```solidity
function transferAdminProject(address admin, string calldata projectId) external override onlyProjectAdmin(projectId);
```

### launch

launch all projects


```solidity
function launch(string calldata projectId, address token)
    external
    override
    onlyProjectAdmin(projectId)
    onlyInitializedProject(projectId);
```

### cancelProject


```solidity
function cancelProject(string calldata projectId)
    external
    override
    ownerOrProjectAdmin(projectId)
    onlyInitializedProject(projectId);
```

### removePool


```solidity
function removePool(string calldata projectId, address pool)
    external
    override
    onlyInitializedProject(projectId)
    onlyProjectAdmin(projectId);
```

### setInitProjectFee


```solidity
function setInitProjectFee(uint256 fee) external override onlyOwner;
```

### setFeesForProject

set fees for project


```solidity
function setFeesForProject(string calldata projectId, uint16 platformFee, uint16 performanceFee)
    external
    override
    onlyOwner;
```

### setILOPoolSaleImplementation


```solidity
function setILOPoolSaleImplementation(address iloPoolSaleImplementation) external override onlyOwner;
```

### project


```solidity
function project(string calldata projectId) external view override returns (Project memory);
```

### _deployIloPool


```solidity
function _deployIloPool(IILOPoolBase.InitPoolBaseParams calldata params, address implementation)
    internal
    returns (address deployedAddress);
```

### _initUniV3PoolIfNecessary


```solidity
function _initUniV3PoolIfNecessary(PoolAddress.PoolKey memory poolKey, uint160 sqrtPriceX96)
    internal
    returns (address pool);
```

### _cancelProject


```solidity
function _cancelProject(Project storage _project) internal;
```

### _checkTicks


```solidity
function _checkTicks(int24 tickLower, int24 tickUpper, uint256 fee, uint160 sqrtPriceX96) internal pure;
```

