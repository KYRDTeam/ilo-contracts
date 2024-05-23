// SPDX-License-Identifier: MIT 

pragma solidity =0.7.6;
pragma abicoder v2;

interface IILOConfig {
    struct LinearVest {
        uint8 percentage;
        uint64 start;
        uint64 end;
    }

    struct InitPoolParams {
        address uniV3Pool;
        int24 tickLower; int24 tickUpper;
        uint256 hardCap; // total amount of raise tokens
        uint256 softCap; // minimum amount of raise token needed for launch pool
        uint256 maxCapPerUser; // TODO: user tiers
        uint64 start;
        uint64 end;
        LinearVest[] investorVestConfigs;
    }
}