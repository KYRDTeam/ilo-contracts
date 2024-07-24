// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;
pragma abicoder v2;

interface IOracleWhitelist {
    struct InitializeParams {
        address owner;
        uint256 maxAddressCap;
        address token;
        address pool;
        address quoteToken;
        uint256 allowedWhitelistIndex;
        bool lockBuy;
    }

    function checkWhitelist(address from, address to, uint256 amount) external;
    function initialize(InitializeParams calldata params) external;
}
