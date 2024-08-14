// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

import '../interfaces/IILOPoolImmutableState.sol';
import '../libraries/PoolAddress.sol';
import '@uniswap/v3-core/contracts/libraries/TickMath.sol';

/// @title Immutable state
/// @notice Immutable state used by periphery contracts
abstract contract ILOPoolImmutableState is IILOPoolImmutableState {
    string public override PROJECT_ID;
    IILOManager public override MANAGER;
    address public override PAIR_TOKEN;
    int24 public override TICK_LOWER;
    int24 public override TICK_UPPER;
    address public override IMPLEMENTATION;
    uint256 public override PROJECT_NONCE;

    address internal _cachedUniV3PoolAddress;
    PoolAddress.PoolKey internal _cachedPoolKey;

    function _initializeImmutableState(
        string memory projectId,
        IILOManager manager,
        address pairToken,
        int24 tickLower,
        int24 tickUpper,
        address implementation,
        uint256 projectNonce
    ) internal {
        require(TICK_LOWER < TICK_UPPER, 'RANGE');
        PROJECT_ID = projectId;
        MANAGER = manager;
        PAIR_TOKEN = pairToken;
        TICK_LOWER = tickLower;
        TICK_UPPER = tickUpper;
        IMPLEMENTATION = implementation;
        PROJECT_NONCE = projectNonce;
    }

    function _sqrtRatioLowerX96()
        internal
        view
        returns (uint160 sqrtRatioLowerX96)
    {
        return TickMath.getSqrtRatioAtTick(TICK_LOWER);
    }

    function _sqrtRatioUpperX96()
        internal
        view
        returns (uint160 sqrtRatioUpperX96)
    {
        return TickMath.getSqrtRatioAtTick(TICK_UPPER);
    }

    function _flipTicks() internal {
        (TICK_LOWER, TICK_UPPER) = (-TICK_UPPER, -TICK_LOWER);
    }
}
