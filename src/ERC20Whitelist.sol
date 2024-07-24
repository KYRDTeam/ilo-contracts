// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;
pragma abicoder v2;

import {IOracleWhitelist} from "./interfaces/IOracleWhitelist.sol";
import {IApproveAndCallReceiver} from "./interfaces/IApproveAndCallReceiver.sol";
import {Initializable} from "./base/Initializable.sol";
import {IERC20Whitelist} from "./interfaces/IERC20Whitelist.sol";
import {ERC20, ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Extended token contract with whitelist contract interactions
 * @notice During whitelist period, `_beforeTokenTransfer` function will call `checkWhitelist` function of whitelist contract
 * @notice If whitelist period is ended, owner will set whitelist contract address back to address(0) and tokens will be transferred freely
 */
contract ERC20Whitelist is IERC20Whitelist, ERC20Burnable, Ownable, Initializable  {
    string private _name;
    string private _symbol;
    /// @dev whitelist contract address
    address private _whitelistContract;

    constructor() ERC20("", "") {
        _disableInitialize();
    }

    function initialize(InitializeParams calldata params) external override whenNotInitialized() {
        _name = params.name;
        _symbol = params.symbol;
        _whitelistContract = params.whitelistContract;
        _mint(params.owner, params.totalSupply);
        transferOwnership(params.owner);
    }

    function approveAndCall(address spender, uint256 amount, bytes calldata extraData) external returns (bool) {
        // Approve the spender to spend the tokens
        _approve(msg.sender, spender, amount);

        // Call the receiveApproval function on the spender contract
        IApproveAndCallReceiver(spender).receiveApproval(msg.sender, amount, address(this), extraData);

        return true;
    }

    /// @notice Before token transfer hook
    /// @dev It will call `checkWhitelist` function and if it's succsessful, it will transfer tokens, unless revert
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        require(to != address(this), "Cannot transfer to the token contract address");
        if (_whitelistContract != address(0)) {
            IOracleWhitelist(_whitelistContract).checkWhitelist(from, to, amount);
        }
        super._beforeTokenTransfer(from, to, amount);
    }
}
