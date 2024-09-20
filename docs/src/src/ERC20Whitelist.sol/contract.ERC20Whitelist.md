# ERC20Whitelist
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/af88dd9b3e8283ab97b6c9511aeb7bb607e3649d/src/ERC20Whitelist.sol)

**Inherits:**
[IERC20Whitelist](/src/interfaces/IERC20Whitelist.sol/interface.IERC20Whitelist.md), ERC20Burnable, ERC20Permit, Ownable

During whitelist period, `_beforeTokenTransfer` function will call `checkWhitelist` function of whitelist contract

If whitelist period is ended, owner will set whitelist contract address back to address(0) and tokens will be transferred freely


## State Variables
### whitelistContract
*whitelist contract address*


```solidity
address public override whitelistContract;
```


## Functions
### constructor


```solidity
constructor(address owner, string memory name, string memory symbol, uint256 _totalSupply, address _whitelistContract)
    ERC20(name, symbol)
    ERC20Permit(name);
```

### removeWhitelistContract


```solidity
function removeWhitelistContract() external override onlyOwner;
```

### _beforeTokenTransfer

Before token transfer hook

*It will call `checkWhitelist` function and if it's succsessful, it will transfer tokens, unless revert*


```solidity
function _beforeTokenTransfer(address from, address to, uint256 amount) internal override;
```

