// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol';
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';
import '@uniswap/v3-core/contracts/interfaces/callback/IUniswapV3MintCallback.sol';

import '../libraries/PoolAddress.sol';
import '../libraries/LiquidityAmounts.sol';
import '../libraries/TransferHelper.sol';
import './ILOPoolImmutableState.sol';

/// @title Liquidity management functions
/// @notice Internal functions for safely managing liquidity in Uniswap V3
abstract contract LiquidityManagement is IUniswapV3MintCallback, ILOPoolImmutableState {
    /// @inheritdoc IUniswapV3MintCallback
    /// @dev liqiuidity is allways in range so we don't need to check if amount0 or amount1 is 0
    function uniswapV3MintCallback(
        uint256 amount0Owed,
        uint256 amount1Owed,
        bytes calldata data
    ) external override {
        require(msg.sender == _cachedUniV3PoolAddress);
        address projectAdmin = abi.decode(data, (address));

        if (_cachedPoolKey.token1 == RAISE_TOKEN) {
            TransferHelper.safeTransferFrom(_cachedPoolKey.token0, projectAdmin, msg.sender, amount0Owed);
            TransferHelper.safeTransfer(_cachedPoolKey.token1, msg.sender, amount1Owed);
        } else {
            TransferHelper.safeTransfer(_cachedPoolKey.token0, msg.sender, amount0Owed);
            TransferHelper.safeTransferFrom(_cachedPoolKey.token1, projectAdmin, msg.sender, amount1Owed);
        }
    }

    struct AddLiquidityParams {
        IUniswapV3Pool pool;
        uint128 liquidity;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        address projectAdmin;
    }

    /// @notice Add liquidity to an initialized pool
    function addLiquidity(AddLiquidityParams memory params)
        internal
        returns (
            uint256 amount0,
            uint256 amount1
        )
    {
        (amount0, amount1) = params.pool.mint(
            address(this),
            TICK_LOWER,
            TICK_UPPER,
            params.liquidity,
            abi.encode(params.projectAdmin)
        );

        require(amount0 >= params.amount0Min && amount1 >= params.amount1Min, 'Price slippage check');
    }
}
