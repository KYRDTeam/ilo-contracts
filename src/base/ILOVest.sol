// SPDX-License-Identifier: BUSL-1.1 

pragma solidity =0.7.6;

import '@uniswap/v3-core/contracts/libraries/FullMath.sol';
import '../interfaces/IILOConfig.sol';

import "forge-std/console.sol";

abstract contract ILOVest is IILOConfig {
    struct PositionVest {
        uint128 totalLiquidity;
        LinearVest[] schedule;
    }

    mapping(uint256=>PositionVest) _positionVests;

    /// @notice calculate amount of liquidity unlocked for claim
    /// @param tokenId nft token id of position
    /// @return liquidityUnlocked amount of unlocked liquidity
    function _unlockedLiquidity(uint256 tokenId) internal view virtual returns (uint128 liquidityUnlocked);

    function _claimableLiquidity(uint256 tokenId) internal view virtual returns (uint128 claimableLiquidity);
}
