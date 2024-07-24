// SPDX-License-Identifier: MIT 

pragma solidity =0.7.6;

import {ERC20} from '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract ERC20Standard is ERC20 {
    constructor(address owner, string memory name, string memory symbol, uint256 totalSupply) ERC20(name, symbol) {
        _mint(owner, totalSupply);
    }
}