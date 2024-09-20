# TokenFactory
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/af88dd9b3e8283ab97b6c9511aeb7bb607e3649d/src/TokenFactory.sol)

**Inherits:**
Ownable, [ITokenFactory](/src/interfaces/ITokenFactory.sol/interface.ITokenFactory.md), [Initializable](/src/base/Initializable.sol/abstract.Initializable.md)


## State Variables
### uniswapV3Factory

```solidity
address public override uniswapV3Factory;
```


### deployedTokens

```solidity
mapping(address => bool) public override deployedTokens;
```


### _nonce

```solidity
uint256 private _nonce = 1;
```


## Functions
### constructor


```solidity
constructor();
```

### initialize


```solidity
function initialize(address _owner, address _uniswapV3Factory) external override whenNotInitialized;
```

### createWhitelistContracts

Create a new ERC20 token and its corresponding whitelist contract


```solidity
function createWhitelistContracts(CreateWhitelistContractsParams calldata params)
    external
    override
    returns (address token, address whitelistAddress);
```

### createStandardERC20Token


```solidity
function createStandardERC20Token(CreateStandardERC20TokenParams calldata params)
    external
    override
    returns (address token);
```

