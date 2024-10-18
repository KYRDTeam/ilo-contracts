// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;
pragma abicoder v2;

interface IOracleWhitelist {
    function token() external view returns (address);
    function pool() external view returns (address);
    function quoteToken() external view returns (address);

    function checkWhitelist(address from, address to, uint256 amount) external;
    function setToken(address _token) external;
    function setPool(address _pool) external;
}
