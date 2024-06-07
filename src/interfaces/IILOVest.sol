// SPDX-License-Identifier: BUSL-1.1 
pragma solidity =0.7.6;
pragma abicoder v2;

interface IILOVest {
    /// @notice return vesting status of position
    function vestingStatus(uint256 tokenId) external returns (
        uint128 unlockedLiquidity,
        uint128 claimedLiquidity
    );
}