// SPDX-License-Identifier: MIT 

pragma solidity =0.7.6;
pragma abicoder v2;

interface IERC20Whitelist {
    struct InitializeParams {
        string name;
        string symbol;
        uint256 totalSupply;
        address owner;
        address whitelistContract;
    }

    function initialize(InitializeParams calldata params) external;
}