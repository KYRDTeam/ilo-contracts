// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import { IUniswapV3Pool } from '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';
import { IUniswapV3MintCallback } from '@uniswap/v3-core/contracts/interfaces/callback/IUniswapV3MintCallback.sol';
import { ILOPoolImmutableState } from './ILOPoolImmutableState.sol';

/// @title Liquidity management functions
/// @notice Internal functions for safely managing liquidity in Uniswap V3
abstract contract LiquidityManagement is
    IUniswapV3MintCallback,
    ILOPoolImmutableState
{
    struct AddLiquidityParams {
        IUniswapV3Pool pool;
        uint128 liquidity;
    }

    /// @inheritdoc IUniswapV3MintCallback
    /// @dev liqiuidity is allways in range so we don't need to check if amount0 or amount1 is 0
    function uniswapV3MintCallback(
        uint256 amount0Owed,
        uint256 amount1Owed,
        bytes calldata data
    ) external override {
        require(msg.sender == _cachedUniV3PoolAddress);
        MANAGER.iloPoolLaunchCallback(
            PROJECT_ID,
            _cachedPoolKey.token0,
            amount0Owed,
            _cachedPoolKey.token1,
            amount1Owed,
            msg.sender
        );
    }

    /// @notice Add liquidity to an initialized pool
    function _addLiquidity(
        AddLiquidityParams memory params
    ) internal returns (uint256 amount0, uint256 amount1) {
        (amount0, amount1) = params.pool.mint(
            address(this),
            TICK_LOWER,
            TICK_UPPER,
            params.liquidity,
            ''
        );
    }
}
