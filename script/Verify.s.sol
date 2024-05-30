// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

import "./Common.s.sol";

contract VerifyILOManagerScript is CommonScript {
    function run() view external {
        address deploymentAddress = getILOManagerDeploymentAddress();
        console.log("deployment address: ", deploymentAddress);
        console.log("\nrun script below to verify contract: \n");
        console.log(
            string(abi.encodePacked(
                "forge verify-contract ", 
                toHexString(deploymentAddress),
                " src/ILOManager.sol:ILOManager"
            ))
        );    
    }
}

contract VerifyILOPoolScript is CommonScript {
    function run() view external {
        address deploymentAddress = getILOPoolDeploymentAddress();
        console.log("deployment address: ", deploymentAddress);
        console.log("\nrun script below to verify contract: \n");
        console.log(
            string(abi.encodePacked(
                "forge verify-contract ", 
                toHexString(deploymentAddress),
                " src/ILOPool.sol:ILOPool"
            ))
        );    
    }
}