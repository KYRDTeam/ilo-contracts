// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;
pragma abicoder v2;

interface IOracleWhitelist {
    function checkWhitelist(address from, address to, uint256 amount) external;
    function setToken(address _token) external;
    function setPool(address _pool) external;
}
