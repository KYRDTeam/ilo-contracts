// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.7.6;
pragma abicoder v2;

import { PoolAddress } from '@uniswap/v3-periphery/contracts/libraries/PoolAddress.sol';

import { ILOPoolBase, FullMath, IILOPoolBase } from './base/ILOPoolBase.sol';
import { IILOPool } from './interfaces/IILOPool.sol';
import { IILOManager } from './interfaces/IILOManager.sol';

/// @title NFT positions
/// @notice Wraps Uniswap V3 positions in the ERC721 non-fungible token interface
contract ILOPool is ILOPoolBase, IILOPool {
    VestingConfig[] private _vestingConfigs;

    function initialize(InitPoolParams calldata params) external override {
        _validateSharesAndVests(params.vestingConfigs);
        _initialize(params.baseParams);
        // initialize vesting
        for (uint256 index = 0; index < params.vestingConfigs.length; index++) {
            _vestingConfigs.push(params.vestingConfigs[index]);
        }
        emit ILOPoolInitialized(
            params.baseParams.projectId,
            params.baseParams.tokenAmount,
            params.baseParams.tickLower,
            params.baseParams.tickUpper,
            params.vestingConfigs
        );
    }

    /// @inheritdoc IILOPoolBase
    function launch(
        address uniV3PoolAddress,
        PoolAddress.PoolKey calldata poolKey,
        uint160 sqrtPriceX96
    ) external override onlyManager onlyInitializedProject {
        uint256 liquidity = _launchLiquidity(
            uniV3PoolAddress,
            poolKey,
            sqrtPriceX96,
            _tokenAmount
        );
    }

    /// @inheritdoc IILOPool
    function distribute(uint256 num) external override afterLaunch {
        uint256 start = _nextId - 1;
        uint256 end = start + num;
        if (end > _vestingConfigs.length) {
            end = _vestingConfigs.length;
        }
        uint128 liquidity = _totalInitialLiquidity;

        // assigning vests for the project configuration
        for (uint256 index = start; index < end; index++) {
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

    /// @inheritdoc IILOPoolBase
    function claim(
        uint256 tokenId
    ) external override returns (uint256 amount0, uint256 amount1) {
        return _claim(tokenId);
    }

    function cancel() external override onlyManager {
        _cancel();
    }

    function _initImplementation() internal override {
        IMPLEMENTATION = IILOManager(MANAGER).ILO_POOL_IMPLEMENTATION();
    }
}
