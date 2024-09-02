// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

import './Common.s.sol';
import '../src/interfaces/IILOManager.sol';
import '../src/interfaces/ITokenFactory.sol';

contract ILOManagerInitializeScript is CommonScript {
    // to ignore coverage
    function testA() public view {}

    function run() external {
        uint256 deployerPrivateKey = vm.envUint('PRIVATE_KEY');
        address deploymentAddress = getILOManagerDeploymentAddress();

        address _feeTaker = vm.envAddress('FEE_TAKER');
        address _initialOwner = vm.envAddress('OWNER');
        uint256 initProjectFee = vm.envUint('INIT_PROJECT_FEE');
        uint16 platformFee = uint16(vm.envUint('PLATFORM_FEE'));
        uint16 performanceFee = uint16(vm.envUint('PERFORMANCE_FEE'));
        address uniV3Factory = vm.envAddress('UNIV3_FACTORY');

        vm.startBroadcast(deployerPrivateKey);
        IILOManager iloManager = IILOManager(deploymentAddress);
        iloManager.initialize(
            _initialOwner,
            _feeTaker,
            getILOPoolDeploymentAddress(),
            getILOPoolSaleDeploymentAddress(),
            uniV3Factory,
            initProjectFee,
            platformFee,
            performanceFee
        );

        vm.stopBroadcast();
    }
}

contract TokenFactoryInitializeScript is CommonScript {
    // to ignore coverage
    function testA() public view {}

    function run() external {
        uint256 deployerPrivateKey = vm.envUint('PRIVATE_KEY');
        address deploymentAddress = getTokenFactoryDeploymentAddress();

        address _initialOwner = vm.envAddress('OWNER');
        address uniV3Factory = vm.envAddress('UNIV3_FACTORY');

        vm.startBroadcast(deployerPrivateKey);
        ITokenFactory tokenFactory = ITokenFactory(deploymentAddress);
        tokenFactory.initialize(_initialOwner, uniV3Factory);

        vm.stopBroadcast();
    }
}
