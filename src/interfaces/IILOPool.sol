// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.7.5;
pragma abicoder v2;

import { IILOVest } from './IILOVest.sol';
import { IILOPoolBase } from './IILOPoolBase.sol';

interface IILOPool {
    event ILOPoolInitialized(
        string projectId,
        uint256 tokenAmount,
        int32 tickLower,
        int32 tickUpper,
        IILOVest.VestingConfig[] vestingConfig
    );

    event ILOPoolSaleInitialized(
        string projectId,
        uint256 tokenAmount,
        int32 tickLower,
        int32 tickUpper,
        IILOVest.VestingConfig[] vestingConfig,
        uint64 saleStart,
        uint64 saleEnd,
        uint256 minRaise,
        uint256 maxRaise
    );

    function initialize(IILOPoolBase.InitPoolParams calldata params) external;
}
