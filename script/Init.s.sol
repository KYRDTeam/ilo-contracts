// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

import "./Common.s.sol";
import "../src/interfaces/IILOManager.sol";

contract ILOManagerInitializeScript is CommonScript {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deploymentAddress = getILOManagerDeploymentAddress();

        address _feeTaker = vm.envAddress("FEE_TAKER");
        address _initialOwner = vm.envAddress("OWNER");
        uint16 platformFee = vm.envAddress("PLATFORM_FEE");
        uint16 performanceFee = vm.envAddress("PERFORMANCE_FEE");

        vm.startBroadcast(deployerPrivateKey);
        IILOManager iloManager = IILOManager(deploymentAddress);
        iloManager.initialize(_initialOwner, _feeTaker, getILOPoolDeploymentAddress(), uniV3Factory, weth9, platformFee, performanceFee);

        vm.stopBroadcast();
    }
}
