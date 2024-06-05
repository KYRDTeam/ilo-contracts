// SPDX-License-Identifier: BUSL-1.1 

pragma solidity =0.7.6;

import '@uniswap/v3-core/contracts/libraries/FullMath.sol';
import '../interfaces/IILOConfig.sol';

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

    /// @notice return number of sharesBPS unlocked upto now
    function _unlockedSharesBPS(LinearVest[] storage vestingSchedule) internal view returns (uint16 unlockedSharesBPS) {
        for (uint256 index = 0; index < vestingSchedule.length; index++) {

            LinearVest storage vest = vestingSchedule[index];

            // if vest is not started, skip this vest and all following vest
            if (block.timestamp < vest.start) {
                break;
            }

            // if vest already end, all the shares are unlocked
            // otherwise we calculate percentage of unlocked times and get the unlocked share number
            // all vest after current unlocking vest is ignored
            if (vest.end < block.timestamp) {
                unlockedSharesBPS += vest.percentage;
            } else {
                unlockedSharesBPS += uint16(FullMath.mulDiv(
                    vest.percentage, 
                    block.timestamp - vest.start, 
                    vest.end - vest.start
                ));
                break;
            }
        }
    }
}
