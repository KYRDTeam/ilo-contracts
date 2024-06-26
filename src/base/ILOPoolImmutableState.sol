// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

import '../interfaces/IILOPoolImmutableState.sol';
import '../libraries/PoolAddress.sol';
import 'v3-core/contracts/libraries/TickMath.sol';

/// @title Immutable state
/// @notice Immutable state used by periphery contracts
abstract contract ILOPoolImmutableState is IILOPoolImmutableState {
    /// @inheritdoc IILOPoolImmutableState
    address public override WETH9;
    string public override PROJECT_ID;
    IILOManager public override MANAGER;
    address public override RAISE_TOKEN;
    int24 public override TICK_LOWER;
    int24 public override TICK_UPPER;
    uint160 public override SQRT_RATIO_X96;
    address public override IMPLEMENTATION;
    uint256 public override POOL_INDEX;

    address internal _cachedUniV3PoolAddress;
    PoolAddress.PoolKey internal _cachedPoolKey;

    function _sqrtRatioLowerX96() internal view returns (uint160 sqrtRatioLowerX96) {
        return TickMath.getSqrtRatioAtTick(TICK_LOWER);
    }

    function _sqrtRatioUpperX96() internal view returns (uint160 sqrtRatioUpperX96) {
        return TickMath.getSqrtRatioAtTick(TICK_UPPER);
    }

    function _flipPriceAndTicks() internal {
        (TICK_LOWER, TICK_UPPER) = (-TICK_UPPER, -TICK_LOWER);
        // SQRT_RATIO_X96 is never 0
        SQRT_RATIO_X96 = uint160(2**192/ SQRT_RATIO_X96);
    }
}
