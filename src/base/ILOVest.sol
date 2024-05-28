// SPDX-License-Identifier: MIT 

pragma solidity =0.7.6;

import '@uniswap/v3-core/contracts/libraries/FullMath.sol';
import '../interfaces/IILOConfig.sol';

abstract contract ILOVest is IILOConfig {
    struct PositionVest {
        uint128 totalLiquidity;
        uint128 claimedLiquidity;
        LinearVest[] schedule;
    }

    mapping(uint256=>PositionVest) _positionVests;

    function _unlockedLiquidity(uint256 tokenId) internal view virtual returns (uint128 unlockedLiquidity);

    function _unlockedSharesBPS(LinearVest[] storage vestingSchedule) internal view returns (uint16 unlockedSharesBPS) {
        for (uint256 index = 0; index < vestingSchedule.length; index++) {

            LinearVest storage vest = vestingSchedule[index];

            if (vest.end < block.timestamp) {
                unlockedSharesBPS += vest.percentage;
            } else if(vest.start < block.timestamp && block.timestamp < vest.end ) {
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