// SPDX-License-Identifier: MIT 
pragma solidity =0.7.6;
pragma abicoder v2;

interface IILOSale {
    /// @notice this function is for investor buying ILO
    function buy(uint256 raiseAmount, address recipient) external returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amountAdded0,
            uint256 amountAdded1
        );
}
