// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;
pragma abicoder v2;

import { IILOVest } from '../src/interfaces/IILOVest.sol';
import { IILOManager } from '../src/interfaces/IILOManager.sol';

contract Mock {
    address public constant DUMMY_ADDRESS =
        0x00000000000000000000000000000000DeaDBeef;
    address public constant DUMMY_ADDRESS_2 =
        0x00000000000000000000000000000000dEadDEaD;
    address public constant DEV_RECIPIENT =
        0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC; // anvil#3
    address public constant TREASURY_RECIPIENT =
        0x90F79bf6EB2c4f870365E785982E1f101E93b906; // anvil#4
    address public constant LIQUIDITY_RECIPIENT =
        0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65; // anvil#5
    address public constant PROJECT_OWNER =
        0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc; // anvil#6
    address public constant INVESTOR =
        0x976EA74026E726554dB657fA54763abd0C3a0aa9; // anvil#7
    address public constant INVESTOR_2 =
        0x976eA74026E726554Db657fA54763abd0C3a0Aa8; // anvil#7

    address public USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; // token0
    address public TOKEN; // token1

    uint64 public constant SALE_START = 1717434000; // Mon Jun 03 2024 17:00:00 GMT+0000
    uint64 public constant SALE_END = 1717520400; // Tue Jun 04 2024 17:00:00 GMT+0000
    uint64 public constant LAUNCH_START = 1717606800; // Wed Jun 05 2024 17:00:00 GMT+0000
    uint64 public constant VEST_START_0 = 1717693200; // Thu Jun 06 2024 17:00:00 GMT+0000
    uint64 public constant VEST_END_0 = 1717779600; // Fri Jun 07 2024 17:00:00 GMT+0000
    uint64 public constant VEST_START_1 = 1717779600; // Sat Jun 07 2024 17:00:00 GMT+0000
    uint64 public constant VEST_END_1 = 1717866000; // Sun Jun 08 2024 17:00:00 GMT+0000

    function _getVestingConfigs()
        internal
        pure
        returns (IILOVest.VestingConfig[] memory vestingConfigs)
    {
        vestingConfigs = new IILOVest.VestingConfig[](3);

        vestingConfigs[0] = IILOVest.VestingConfig({
            shares: 3000, // 30%
            recipient: TREASURY_RECIPIENT,
            schedule: _getLinearVesting()
        });
        vestingConfigs[1] = IILOVest.VestingConfig({
            shares: 3000, // 30%
            recipient: DEV_RECIPIENT,
            schedule: _getLinearVesting()
        });
        vestingConfigs[2] = IILOVest.VestingConfig({
            shares: 4000, // 40%
            recipient: LIQUIDITY_RECIPIENT,
            schedule: _getLinearVesting()
        });
    }

    function _getLinearVesting()
        internal
        pure
        returns (IILOVest.LinearVest[] memory linearVestConfigs)
    {
        linearVestConfigs = new IILOVest.LinearVest[](2);
        linearVestConfigs[0] = IILOVest.LinearVest({
            shares: 3000, // 30%
            start: VEST_START_0,
            end: VEST_END_0
        });
        linearVestConfigs[1] = IILOVest.LinearVest({
            shares: 7000, // 70%
            start: VEST_START_1,
            end: VEST_END_1
        });
    }
}
