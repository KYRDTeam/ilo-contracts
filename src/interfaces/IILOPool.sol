// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.7.5;
pragma abicoder v2;

import { IILOVest } from './IILOVest.sol';
import { IILOPoolBase } from './IILOPoolBase.sol';

interface IILOPool {
    event ILOPoolInitialized(
        string projectId,
        int32 tickLower,
        int32 tickUpper,
        IILOVest.VestingConfig[] vestingConfig
    );

    function initialize(IILOPoolBase.InitPoolParams calldata params) external;
}
