// SPDX-License-Identifier: BUSL-1.1 
pragma solidity =0.7.6;
pragma abicoder v2;

interface IILOVest {
    /// @notice return claimable liquidity associated with tokenId
    function claimableLiquidity(uint256 tokenId) external view returns(uint128);

    /// @notice return claimed liquidity associated with tokenId
    function claimedLiquidity(uint256 tokenId) external view returns(uint128);
}