# ITokenFactory
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/ae631fe4bfbce302e21cc5e317f651168c939703/src/interfaces/ITokenFactory.sol)


## Functions
### createWhitelistContracts


```solidity
function createWhitelistContracts(CreateWhitelistContractsParams calldata params)
    external
    returns (address token, address whitelistAddress);
```

### createStandardERC20Token


```solidity
function createStandardERC20Token(CreateStandardERC20TokenParams calldata params) external returns (address token);
```

### initialize


```solidity
function initialize(address _owner, address _uniswapV3Factory) external;
```

### uniswapV3Factory


```solidity
function uniswapV3Factory() external view returns (address);
```

## Events
### TokenCreated

```solidity
event TokenCreated(address indexed tokenAddress, CreateERC20WhitelistTokenParams params);
```

### OracleWhitelistCreated

```solidity
event OracleWhitelistCreated(address indexed whitelistAddress, CreateOracleWhitelistParams params);
```

### ERC20WhitelistImplementationSet

```solidity
event ERC20WhitelistImplementationSet(address oldImplementation, address newImplementation);
```

### OracleWhitelistImplementationSet

```solidity
event OracleWhitelistImplementationSet(address oldImplementation, address newImplementation);
```

## Structs
### CreateOracleWhitelistParams

```solidity
struct CreateOracleWhitelistParams {
    uint256 maxAddressCap;
    address token;
    address pool;
    address quoteToken;
    bool lockBuy;
}
```

### CreateERC20WhitelistTokenParams

```solidity
struct CreateERC20WhitelistTokenParams {
    string name;
    string symbol;
    uint256 totalSupply;
    address whitelistContract;
}
```

### CreateStandardERC20TokenParams

```solidity
struct CreateStandardERC20TokenParams {
    string name;
    string symbol;
    uint256 totalSupply;
}
```

### CreateWhitelistContractsParams

```solidity
struct CreateWhitelistContractsParams {
    string name;
    string symbol;
    uint256 totalSupply;
    uint256 maxAddressCap;
    address quoteToken;
    bool lockBuy;
    uint24 fee;
}
```

