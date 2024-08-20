// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.5;
pragma abicoder v2;

import { IERC721Metadata } from '@openzeppelin/contracts/token/ERC721/IERC721Metadata.sol';
import { IERC721Enumerable } from '@openzeppelin/contracts/token/ERC721/IERC721Enumerable.sol';

import { IILOVest } from './IILOVest.sol';
import { PoolAddress } from '../libraries/PoolAddress.sol';

/// @title Non-fungible token for positions
/// @notice Wraps Uniswap V3 positions in a non-fungible token interface which allows for them to be transferred
/// and authorized.
interface IILOPoolBase is IERC721Metadata, IERC721Enumerable {
    // details about the uniswap position
    struct Position {
        // the liquidity of the position
        uint128 liquidity;
        // the fee growth of the aggregate position as of the last action on the individual position
        uint256 feeGrowthInside0LastX128;
        uint256 feeGrowthInside1LastX128;
        // the raise amount of position
        uint256 raiseAmount;
    }

    struct InitPoolBaseParams {
        string projectId;
        uint256 tokenAmount;
        int24 tickLower;
        int24 tickUpper;
    }

    struct InitPoolParams {
        InitPoolBaseParams baseParams;
        // config for vests and shares.
        IILOVest.VestingConfig[] vestingConfigs;
    }

    /// @notice Emitted when liquidity is increased for a position NFT
    /// @dev Also emitted when a token is minted
    /// @param tokenId The ID of the token for which liquidity was increased
    /// @param liquidity The amount by which liquidity for the NFT position was increased
    /// @param amount0 The amount of token0 that was paid for the increase in liquidity
    /// @param amount1 The amount of token1 that was paid for the increase in liquidity
    event IncreaseLiquidity(
        uint256 indexed tokenId,
        uint128 liquidity,
        uint256 amount0,
        uint256 amount1
    );

    /// @notice Emitted when liquidity is decreased for a position NFT
    /// @param tokenId The ID of the token for which liquidity was decreased
    /// @param liquidity The amount by which liquidity for the NFT position was decreased
    /// @param amount0 The amount of token0 that was accounted for the decrease in liquidity
    /// @param amount1 The amount of token1 that was accounted for the decrease in liquidity
    event DecreaseLiquidity(
        uint256 indexed tokenId,
        uint128 liquidity,
        uint256 amount0,
        uint256 amount1
    );

    /// @notice Emitted when tokens are collected for a position NFT
    /// @dev The amounts reported may not be exactly equivalent to the amounts transferred, due to rounding behavior
    /// @param tokenId The ID of the token for which underlying tokens were collected
    /// @param recipient The address of the account that received the collected tokens
    /// @param amount0 The amount of token0 owed to the position that was collected
    /// @param amount1 The amount of token1 owed to the position that was collected
    event Collect(
        uint256 indexed tokenId,
        address recipient,
        uint256 amount0,
        uint256 amount1
    );

    event Claim(
        address indexed user,
        uint256 tokenId,
        uint128 liquidity,
        uint256 amount0WithFee,
        uint256 amount1WithFee,
        uint256 feeGrowthInside0LastX128,
        uint256 feeGrowthInside1LastX128,
        uint256 fee0Claimed,
        uint256 fee1Claimed
    );
    event Buy(address indexed investor, uint256 tokenId, uint256 raiseAmount);
    event PoolLaunch(
        address indexed project,
        uint128 liquidity,
        uint256 token0,
        uint256 token1
    );
    event PoolCancelled();
    event Refund(address indexed owner, uint256 tokenId, uint256 refundAmount);
    event ProjectRefund(address indexed projectAdmin, uint256 saleTokenAmount);

    /// @notice Returns number of collected tokens associated with a given token ID.
    function claim(
        uint256 tokenId
    ) external returns (uint256 amount0, uint256 amount1);

    function launch(
        address uniV3PoolAddress,
        PoolAddress.PoolKey calldata poolKey,
        uint160 sqrtPriceX96
    ) external;

    function cancel() external;

    function CANCELLED() external view returns (bool);
}
