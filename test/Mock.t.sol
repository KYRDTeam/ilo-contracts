// SPDX-License-Identifier: MIT 

pragma solidity =0.7.6;
pragma abicoder v2;
import "../src/ILOManager.sol";

contract Mock {
    struct Project {
        address saleToken;
        address raiseToken;
        uint24 fee;
        uint160 initialPoolPriceX96;
        uint64 launchTime;
        uint16 investorShares;  // BPS shares
        IILOManager.ProjectVestConfig[] projectVestConfigs;

    }


    address constant DEV_RECIPIENT = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC; // anvil#3
    address constant TREASURY_RECIPIENT = 0x90F79bf6EB2c4f870365E785982E1f101E93b906; // anvil#4
    address constant LIQUIDITY_RECIPIENT = 0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65; // anvil#5
    address constant PROJECT_OWNER = 0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc; // anvil#6
    address USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address SALE_TOKEN;
    
    function mockProject() internal view returns(Project memory) {
        return Project({
            saleToken: SALE_TOKEN, 
            raiseToken: USDT,
            fee: 3000,
            initialPoolPriceX96: 39614081257132168796771975168, 
            launchTime: 1717606800, // Wed Jun 05 2024 17:00:00 GMT+0000
            investorShares: 2000, // 20%
            projectVestConfigs: _getProjectVestConfig()
        });
    }

    function _getProjectVestConfig() internal pure returns (IILOManager.ProjectVestConfig[] memory projectVestConfigs) {
        projectVestConfigs = new IILOManager.ProjectVestConfig[](3);
        projectVestConfigs[0] = IILOManager.ProjectVestConfig({
                    shares: 2000, // 20%
                    name: "dev",
                    recipient: DEV_RECIPIENT,
                    vestSchedule: _getProjectLinearVesting()
            });
        projectVestConfigs[1] = IILOManager.ProjectVestConfig({
                    shares: 3000, // 30%
                    name: "treasury",
                    recipient: TREASURY_RECIPIENT,
                    vestSchedule: _getProjectLinearVesting()
            });
        projectVestConfigs[2] = IILOManager.ProjectVestConfig({
                    shares: 3000, // 30%
                    name: "liquidity",
                    recipient: LIQUIDITY_RECIPIENT,
                    vestSchedule: _getProjectLinearVesting()
            });
    }

    function _getProjectLinearVesting() internal pure returns (IILOConfig.LinearVest[] memory linearVestConfigs) {
        linearVestConfigs = new IILOConfig.LinearVest[](2);
        linearVestConfigs[0] = IILOConfig.LinearVest({
                    percentage: 3000, // 30% 
                    start: 1717693200, // Thu Jun 06 2024 17:00:00 GMT+0000
                    end: 1717779600 // Fri Jun 07 2024 17:00:00 GMT+0000
            });
        linearVestConfigs[1] = IILOConfig.LinearVest({
                    percentage: 7000, // 70% 
                    start: 1717779600, // Fri Jun 07 2024 17:00:00 GMT+0000
                    end: 1717866000 // Sat Jun 08 2024 17:00:00 GMT+0000
            });
    }
}
