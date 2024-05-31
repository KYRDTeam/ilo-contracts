// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

import "./Common.s.sol";

contract ILOManagerScript is CommonScript {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        ILOManager ilo = new ILOManager{
            salt: salt
        }();

        vm.stopBroadcast();
    }
}
