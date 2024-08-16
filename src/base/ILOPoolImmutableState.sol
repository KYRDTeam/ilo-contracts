// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import { IILOManager } from '../interfaces/IILOManager.sol';
import { IILOPoolImmutableState } from '../interfaces/IILOPoolImmutableState.sol';
import { PoolAddress } from '../libraries/PoolAddress.sol';
import { TickMath } from '@uniswap/v3-core/contracts/libraries/TickMath.sol';

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
        int24 tickLower,
        int24 tickUpper
    ) internal {
        IILOManager.Project memory _project = manager.project(projectId);
        require(TICK_LOWER < TICK_UPPER, 'RANGE');
        PROJECT_ID = projectId;
        MANAGER = manager;
        PAIR_TOKEN = _project.pairToken;
        TICK_LOWER = tickLower;
        TICK_UPPER = tickUpper;
        _initImplementation();
    }

    /// @notice this function to be implemented in the ilo pool and ilo pool sale
    /// each contract will have its own implementation
    function _initImplementation() internal virtual;

    function _flipTicks() internal {
        (TICK_LOWER, TICK_UPPER) = (-TICK_UPPER, -TICK_LOWER);
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
}
