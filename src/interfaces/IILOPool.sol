// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.5;
pragma abicoder v2;

import '@openzeppelin/contracts/token/ERC721/IERC721Metadata.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721Enumerable.sol';

import './IILOConfig.sol';
import './IPeripheryPayments.sol';
import './IILOPoolImmutableState.sol';
import './IILOSale.sol';
import './IILOVest.sol';
import '../libraries/PoolAddress.sol';

/// @title Non-fungible token for positions
/// @notice Wraps Uniswap V3 positions in a non-fungible token interface which allows for them to be transferred
/// and authorized.
interface IILOPool is
    IILOConfig,
    IILOVest,
    IILOSale,
    IPeripheryPayments,
    IILOPoolImmutableState,
    IERC721Metadata,
    IERC721Enumerable
{
    /// @notice Emitted when liquidity is increased for a position NFT
    /// @dev Also emitted when a token is minted
    /// @param tokenId The ID of the token for which liquidity was increased
    /// @param liquidity The amount by which liquidity for the NFT position was increased
    /// @param amount0 The amount of token0 that was paid for the increase in liquidity
    /// @param amount1 The amount of token1 that was paid for the increase in liquidity
    event IncreaseLiquidity(uint256 indexed tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);

    /// @notice Emitted when liquidity is decreased for a position NFT
    /// @param tokenId The ID of the token for which liquidity was decreased
    /// @param liquidity The amount by which liquidity for the NFT position was decreased
    /// @param amount0 The amount of token0 that was accounted for the decrease in liquidity
    /// @param amount1 The amount of token1 that was accounted for the decrease in liquidity
    event DecreaseLiquidity(uint256 indexed tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);

    /// @notice Emitted when tokens are collected for a position NFT
    /// @dev The amounts reported may not be exactly equivalent to the amounts transferred, due to rounding behavior
    /// @param tokenId The ID of the token for which underlying tokens were collected
    /// @param recipient The address of the account that received the collected tokens
    /// @param amount0 The amount of token0 owed to the position that was collected
    /// @param amount1 The amount of token1 owed to the position that was collected
    event Collect(uint256 indexed tokenId, address recipient, uint256 amount0, uint256 amount1);

    event ILOPoolInitialized(address indexed univ3Pool, int32 tickLower, int32 tickUpper, uint16 platformFee, uint16 performanceFee, uint16 investorShares, SaleInfo saleInfo, LinearVest[] investorVestConfigs);

    event Claim(address indexed user, uint128 liquidity, uint256 amount0, uint256 amount1);
    event Buy(address indexed investor, uint256 tokenId, uint256 raiseAmount, uint128 liquidity);
    event PoolLaunch(address indexed project, uint128 liquidity, uint256 token0, uint256 token1);
    event UserRefund(address indexed user, uint256 raiseTokenAmount);
    event ProjectRefund(address indexed projectAdmin, uint256 saleTokenAmount);

    /// @notice Returns the position information associated with a given token ID.
    /// @dev Throws if the token ID is not valid.
    /// @param tokenId The ID of the token that represents the position
    /// @return token0 The address of the token0 for a specific pool
    /// @return token1 The address of the token1 for a specific pool
    /// @return fee The fee associated with the pool
    /// @return tickLower The lower end of the tick range for the position
    /// @return tickUpper The higher end of the tick range for the position
    /// @return liquidity The liquidity of the position
    /// @return feeGrowthInside0LastX128 The fee growth of token0 as of the last action on the individual position
    /// @return feeGrowthInside1LastX128 The fee growth of token1 as of the last action on the individual position
    function positions(uint256 tokenId)
        external
        view
        returns (
            address token0,
            address token1,
            uint24 fee,
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128
        );

    /// @notice Returns number of collected tokens associated with a given token ID.
    function claim(uint256 tokenId) external payable returns (uint256 amount0, uint256 amount1);

    /// @notice Burns a token ID, which deletes it from the NFT contract. The token must have 0 liquidity and all tokens
    /// must be collected first.
    /// @param tokenId The ID of the token that is being burned
    function burn(uint256 tokenId) external payable;

    function initialize(InitPoolParams calldata initPoolParams) external;

    function launch() external;

    /// @notice project admin claim refund sale token
    function claimProjectRefund(address projectAdmin) external returns (uint256 refundAmount);

    /// @notice user claim refund when refund conditions are met
    function claimRefund(uint256 tokenId) external;
}
