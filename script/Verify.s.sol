// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

import { CommonScript } from './Common.s.sol';
import { console } from 'forge-std/Script.sol';

contract VerifyAllContractsScript is CommonScript {
    // to ignore coverage
    function testA() public view {}

    function run() external view {
        address iloManagerDeploymentAddress = getILOManagerDeploymentAddress();
        console.log(
            'iloManager deployment address: ',
            iloManagerDeploymentAddress
        );

        address iloPoolDeploymentAddress = getILOPoolDeploymentAddress();
        console.log('iloPool deployment address: ', iloPoolDeploymentAddress);

        address iloPoolSaleDeploymentAddress = getILOPoolSaleDeploymentAddress();
        console.log(
            'iloPoolSale deployment address: ',
            iloPoolSaleDeploymentAddress
        );

        console.log('\nrun script below to verify all contracts: \n');

        console.log(
            string(
                abi.encodePacked(
                    'forge verify-contract ',
                    toHexString(iloPoolDeploymentAddress),
                    ' src/ILOPool.sol:ILOPool;',
                    'forge verify-contract ',
                    toHexString(iloPoolSaleDeploymentAddress),
                    ' src/ILOPoolSale.sol:ILOPoolSale;',
                    'forge verify-contract ',
                    toHexString(iloManagerDeploymentAddress),
                    ' src/ILOManager.sol:ILOManager'
                )
            )
        );
    }
}

contract VerifyILOManagerScript is CommonScript {
    // to ignore coverage
    function testA() public view {}

    function run() external view {
        address deploymentAddress = getILOManagerDeploymentAddress();
        console.log('deployment address: ', deploymentAddress);
        console.log('\nrun script below to verify contract: \n');
        console.log(
            string(
                abi.encodePacked(
                    'forge verify-contract ',
                    toHexString(deploymentAddress),
                    ' src/ILOManager.sol:ILOManager'
                )
            )
        );
    }
}

contract VerifyILOPoolScript is CommonScript {
    // to ignore coverage
    function testA() public view {}

    function run() external view {
        address deploymentAddress = getILOPoolDeploymentAddress();
        console.log('deployment address: ', deploymentAddress);
        console.log('\nrun script below to verify contract: \n');
        console.log(
            string(
                abi.encodePacked(
                    'forge verify-contract ',
                    toHexString(deploymentAddress),
                    ' src/ILOPool.sol:ILOPool'
                )
            )
        );
    }
}

contract VerifyILOPoolSaleScript is CommonScript {
    // to ignore coverage
    function testA() public view {}

    function run() external view {
        address deploymentAddress = getILOPoolSaleDeploymentAddress();
        console.log('deployment address: ', deploymentAddress);
        console.log('\nrun script below to verify contract: \n');
        console.log(
            string(
                abi.encodePacked(
                    'forge verify-contract ',
                    toHexString(deploymentAddress),
                    ' src/ILOPoolSale.sol:ILOPoolSale'
                )
            )
        );
    }
}

contract VerifyTokenFactoryScript is CommonScript {
    // to ignore coverage
    function testA() public view {}

    function run() external view {
        address deploymentAddress = getTokenFactoryDeploymentAddress();
        console.log('deployment address: ', deploymentAddress);
        console.log('\nrun script below to verify contract: \n');
        console.log(
            string(
                abi.encodePacked(
                    'forge verify-contract ',
                    toHexString(deploymentAddress),
                    ' src/TokenFactory.sol:TokenFactory'
                )
            )
        );
    }
}
