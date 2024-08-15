// SPDX-License-Identifier: MIT

pragma solidity =0.7.6;

import { ERC20, ERC20Permit } from '@openzeppelin/contracts/drafts/ERC20Permit.sol';

contract ERC20Standard is ERC20Permit {
    constructor(
        address owner,
        string memory name,
        string memory symbol,
        uint256 totalSupply
    ) ERC20(name, symbol) ERC20Permit(name) {
        _mint(owner, totalSupply);
    }
}
