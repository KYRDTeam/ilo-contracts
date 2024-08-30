// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.7.6;
pragma abicoder v2;

interface IILOVest {
    struct VestingConfig {
        // how many shares(in total ilo pool's liquidity) will be vested
        uint16 shares;
        // who will receive the shares
        address recipient;
        // the vesting schedule
        LinearVest[] schedule;
    }

    struct LinearVest {
        // how many shares(in total this wallet's liquidity) will be vested
        uint16 shares;
        // when the vesting starts
        uint64 start;
        // when the vesting ends
        uint64 end;
    }

    struct PositionVest {
        // total liquidity of the position
        uint128 totalLiquidity;
        // the vesting schedule
        LinearVest[] schedule;
    }
}
