// SPDX-License-Identifier: BUSL-1.1 
pragma solidity =0.7.6;
pragma abicoder v2;

interface IILOSale {
    struct SaleInfo {
        uint256 maxRaise; // total amount of raise tokens
        uint256 minRaise; // minimum amount of raise token needed for launch pool
        uint256 maxRaisePerUser; // TODO: user tiers
        uint64 start;
        uint64 end;
    }
    /// @notice this function is for investor buying ILO
    function buy(uint256 raiseAmount, address recipient) external returns (
            uint256 tokenId
        );
}
