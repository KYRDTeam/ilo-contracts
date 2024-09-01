# ERC20Standard
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/ae631fe4bfbce302e21cc5e317f651168c939703/src/base/ERC20Standard.sol)

**Inherits:**
ERC20Permit


## Functions
### constructor


```solidity
constructor(address owner, string memory name, string memory symbol, uint256 totalSupply)
    ERC20(name, symbol)
    ERC20Permit(name);
```

