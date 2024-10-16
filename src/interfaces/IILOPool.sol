// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.7.5;
pragma abicoder v2;

import { IILOVest } from './IILOVest.sol';
import { IILOPoolBase } from './IILOPoolBase.sol';

interface IILOPool is IILOPoolBase {
    event ILOPoolInitialized(
        string projectId,
        uint256 tokenAmount,
        int32 tickLower,
        int32 tickUpper,
        IILOVest.VestingConfig[] vestingConfig
    );

    function initialize(InitPoolParams calldata params) external;
    function distribute(uint256 num) external;
}
