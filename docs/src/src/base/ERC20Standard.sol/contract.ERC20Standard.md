# ERC20Standard
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/e40a6cd6fab3cc84638afa793f4d9e791b183158/src/base/ERC20Standard.sol)

**Inherits:**
ERC20Permit


## Functions
### constructor


```solidity
constructor(address owner, string memory name, string memory symbol, uint256 totalSupply)
    ERC20(name, symbol)
    ERC20Permit(name);
```

