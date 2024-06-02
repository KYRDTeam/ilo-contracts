// SPDX-License-Identifier: BUSL-1.1 
pragma solidity =0.7.6;
pragma abicoder v2;

interface IILOSale {
    struct SaleInfo {
        uint256 hardCap; // total amount of raise tokens
        uint256 softCap; // minimum amount of raise token needed for launch pool
        uint256 maxCapPerUser; // TODO: user tiers
        uint64 start;
        uint64 end;
        uint256 maxSaleAmount; // maximum amount of sale tokens
    }

    /// @notice this function is for investor buying ILO
    function buy(uint256 raiseAmount, address recipient) external returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amountAdded0,
            uint256 amountAdded1
        );
}
