// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.7.6;
pragma abicoder v2;

import {ILOPoolBase, IILOManager, FullMath, IUniswapV3Pool, LiquidityAmounts} from './base/ILOPoolBase.sol';
import {IILOPool, PoolAddress} from './interfaces/IILOPool.sol';
/// @title NFT positions
/// @notice Wraps Uniswap V3 positions in the ERC721 non-fungible token interface
contract ILOPool is ILOPoolBase, IILOPool {
    VestingConfig[] private _vestingConfigs;

    function name() public pure override returns (string memory) {
        return 'KRYSTAL ILOPool V3';
    }

    function initialize(
        InitPoolParams calldata params
    ) external override OnlyManager {
        _initialize(params);
        // initialize vesting
        for (uint256 index = 0; index < params.vestingConfigs.length; index++) {
            _vestingConfigs.push(params.vestingConfigs[index]);
        }
    }

    function symbol() public pure override returns (string memory) {
        return 'KRYSTAL-ILO-V3';
    }

    /// @inheritdoc IILOPool
    function launch(
        address uniV3PoolAddress,
        PoolAddress.PoolKey calldata poolKey,
        uint160 sqrtPriceX96
    ) external override OnlyManager {
        uint256 liquidity = _launchLiquidity(
            uniV3PoolAddress,
            poolKey,
            sqrtPriceX96,
            _tokenAmount
        );

        // assigning vests for the project configuration
        for (uint256 index = 0; index < _vestingConfigs.length; index++) {
            uint256 tokenId = _nextId++;
            VestingConfig memory projectConfig = _vestingConfigs[index];
            // mint nft for recipient
            _mint(projectConfig.recipient, tokenId);
            uint128 liquidityShares = uint128(
                FullMath.mulDiv(liquidity, projectConfig.shares, BPS)
            ); // BPS = 10000

            Position storage _position = _positions[tokenId];
            _position.liquidity = liquidityShares;
            _positionVests[tokenId].totalLiquidity = liquidityShares;

            // assign vesting schedule
            LinearVest[] storage schedule = _positionVests[tokenId].schedule;
            for (uint256 i = 0; i < projectConfig.schedule.length; i++) {
                schedule.push(projectConfig.schedule[i]);
            }

            emit Buy(projectConfig.recipient, tokenId, 0);
        }
    }
}
