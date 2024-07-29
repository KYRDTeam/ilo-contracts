// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

interface IUniswapV3Oracle {
    /// @notice TWAP period
    function PERIOD() external view returns (uint32);
    /// @notice Will calculate 1 TK price in ETH
    function BASE_AMOUNT() external view returns (uint128);

    /// @notice return pool address of base/quote pair
    function pool() external view returns (address);
    /// @notice return token address
    function token() external view returns (address);
    /// @notice quote token address
    function quoteToken() external view returns (address);
}
