# IILOManager
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/af88dd9b3e8283ab97b6c9511aeb7bb607e3649d/src/interfaces/IILOManager.sol)


## Functions
### initProject

init project with details


```solidity
function initProject(InitProjectParams calldata params) external payable;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`params`|`InitProjectParams`|the parameters to initialize the project|


### initILOPool

this function init an `ILO Pool` which will be used for sale and vest. One project can init many ILO Pool

only project admin can use this function


```solidity
function initILOPool(IILOPoolBase.InitPoolParams calldata params) external returns (address iloPoolAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`params`|`IILOPoolBase.InitPoolParams`|the parameters for init project|


### initILOPoolSale


```solidity
function initILOPoolSale(IILOPoolSale.InitParams calldata params) external returns (address iloPoolSaleAddress);
```

### setFeeTaker

set platform fee for decrease liquidity. Platform fee is imutable among all project's pools


```solidity
function setFeeTaker(address _feeTaker) external;
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
) external;
```

### launch

launch all projects


```solidity
function launch(string calldata projectId, address saleToken) external;
```

### setILOPoolImplementation

new ilo implementation for clone


```solidity
function setILOPoolImplementation(address iloPoolImplementation) external;
```

### setILOPoolSaleImplementation

new ilo sale implementation for clone


```solidity
function setILOPoolSaleImplementation(address iloPoolSaleImplementation) external;
```

### transferAdminProject

transfer admin of project


```solidity
function transferAdminProject(address admin, string calldata projectId) external;
```

### cancelProject

cancel project


```solidity
function cancelProject(string calldata projectId) external;
```

### removePool

cancel pool


```solidity
function removePool(string calldata projectId, address pool) external;
```

### setInitProjectFee


```solidity
function setInitProjectFee(uint256 fee) external;
```

### setPlatformFee


```solidity
function setPlatformFee(uint16 fee) external;
```

### setPerformanceFee


```solidity
function setPerformanceFee(uint16 fee) external;
```

### setTokenFactory


```solidity
function setTokenFactory(address _tokenFactory) external;
```

### onPoolSaleFail

callback when pool sale fail
cancel all pool of project, same as cancel project


```solidity
function onPoolSaleFail(string calldata projectId) external;
```

### setFeesForProject

set fees for project


```solidity
function setFeesForProject(string calldata projectId, uint16 platformFee, uint16 performanceFee) external;
```

### iloPoolLaunchCallback


```solidity
function iloPoolLaunchCallback(
    string calldata projectId,
    address token0,
    uint256 amount0,
    address token1,
    uint256 amount1,
    address uniswapV3Pool
) external;
```

### project


```solidity
function project(string memory projectId) external view returns (Project memory);
```

### UNIV3_FACTORY


```solidity
function UNIV3_FACTORY() external view returns (address);
```

### TOKEN_FACTORY


```solidity
function TOKEN_FACTORY() external view returns (address);
```

### PLATFORM_FEE


```solidity
function PLATFORM_FEE() external view returns (uint16);
```

### PERFORMANCE_FEE


```solidity
function PERFORMANCE_FEE() external view returns (uint16);
```

### FEE_TAKER


```solidity
function FEE_TAKER() external view returns (address);
```

### ILO_POOL_IMPLEMENTATION


```solidity
function ILO_POOL_IMPLEMENTATION() external view returns (address);
```

### ILO_POOL_SALE_IMPLEMENTATION


```solidity
function ILO_POOL_SALE_IMPLEMENTATION() external view returns (address);
```

### INIT_PROJECT_FEE


```solidity
function INIT_PROJECT_FEE() external view returns (uint256);
```

## Events
### ProjectCreated

```solidity
event ProjectCreated(string projectId, Project project);
```

### ILOPoolCreated

```solidity
event ILOPoolCreated(string projectId, address indexed pool);
```

### PoolImplementationChanged

```solidity
event PoolImplementationChanged(address indexed oldPoolImplementation, address indexed newPoolImplementation);
```

### ProjectAdminChanged

```solidity
event ProjectAdminChanged(string projectId, address oldAdmin, address newAdmin);
```

### ProjectLaunch

```solidity
event ProjectLaunch(string projectId, address uniswapV3Pool, address saleToken);
```

### FeesForProjectSet

```solidity
event FeesForProjectSet(string projectId, uint16 platformFee, uint16 performanceFee);
```

### ProjectCancelled

```solidity
event ProjectCancelled(string projectId);
```

### PoolCancelled

```solidity
event PoolCancelled(string projectId, address pool);
```

### PoolSaleImplementationChanged

```solidity
event PoolSaleImplementationChanged(
    address indexed oldPoolSaleImplementation, address indexed newPoolSaleImplementation
);
```

### InitProjectFeeChanged

```solidity
event InitProjectFeeChanged(uint256 oldFee, uint256 newFee);
```

### FeeTakerChanged

```solidity
event FeeTakerChanged(address oldFeeTaker, address newFeeTaker);
```

### PlatformFeeChanged

```solidity
event PlatformFeeChanged(uint16 oldFee, uint16 newFee);
```

### PerformanceFeeChanged

```solidity
event PerformanceFeeChanged(uint16 oldFee, uint16 newFee);
```

### TokenFactoryChanged

```solidity
event TokenFactoryChanged(address oldTokenFactory, address newTokenFactory);
```

## Structs
### Project

```solidity
struct Project {
    string projectId;
    address admin;
    address pairToken;
    uint24 fee;
    uint160 initialPoolPriceX96;
    uint16 platformFee;
    uint16 performanceFee;
    uint16 nonce;
    bool useTokenFactory;
    string tokenSymbol;
    uint256 totalSupply;
    ProjectStatus status;
}
```

### InitProjectParams

```solidity
struct InitProjectParams {
    string projectId;
    address pairToken;
    uint160 initialPoolPriceX96;
    uint24 fee;
    bool useTokenFactory;
    string tokenSymbol;
    uint256 totalSupply;
}
```

## Enums
### ProjectStatus

```solidity
enum ProjectStatus {
    INVALID,
    INITIALIZED,
    LAUNCHED,
    CANCELLED
}
```

