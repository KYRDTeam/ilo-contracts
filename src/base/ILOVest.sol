// SPDX-License-Identifier: BUSL-1.1 

pragma solidity =0.7.6;

import '../interfaces/IILOVest.sol';
import './ILOPoolImmutableState.sol';

abstract contract ILOVest is IILOVest, ILOPoolImmutableState {
    mapping(uint256=>PositionVest) _positionVests;

    function _validateSharesAndVests(uint64 launchTime, VestingConfig[] memory vestingConfigs) internal pure {
        uint16 totalShares;
        for (uint256 i = 0; i < vestingConfigs.length; i++) {
            if (i == 0) {
                require (vestingConfigs[i].recipient == address(0), "VR");
            } else {
                require(vestingConfigs[i].recipient != address(0), "VR");
            }
            // we need to subtract fist in order to avoid int overflow
            require(BPS - totalShares >= vestingConfigs[i].shares, "TS");
            _validateVestSchedule(launchTime, vestingConfigs[i].schedule);
            totalShares += vestingConfigs[i].shares;
        }
        // total shares should be exactly equal BPS
        require(totalShares == BPS, "TS");
    }

    function _validateVestSchedule(uint64 launchTime, LinearVest[] memory schedule) internal pure {
        require(schedule[0].start >= launchTime, "VT");
        uint16 totalShares;
        uint64 lastEnd;
        uint256 scheduleLength = schedule.length;
        for (uint256 i = 0; i < scheduleLength; i++) {
            // vesting schedule must not overlap
            require(schedule[i].start >= lastEnd, "VT");
            require(schedule[i].start < schedule[i].end, "VT");
            lastEnd = schedule[i].end;
            // we need to subtract fist in order to avoid int overflow
            require(BPS - totalShares >= schedule[i].shares, "VS");
            totalShares += schedule[i].shares;
        }
        // total shares should be exactly equal BPS
        require(totalShares == BPS, "VS");
    }
}
