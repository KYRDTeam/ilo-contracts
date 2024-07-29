// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

import "./Common.s.sol";

contract AllContractScript is CommonScript {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address uniV3Factory = vm.envAddress("UNIV3_FACTORY");
        vm.startBroadcast(deployerPrivateKey);
        // create contracts
        {
            ILOPool iloPool = new ILOPool{
                salt: salt
            }();

            ILOManager ilo = new ILOManager{
                salt: salt
            }();
        }

        // initialize ilo manager
        {
            address _feeTaker = vm.envAddress("FEE_TAKER");
            address _initialOwner = vm.envAddress("OWNER");
            uint256 initProjectFee = vm.envUint("INIT_PROJECT_FEE");
            uint16 platformFee = uint16(vm.envUint("PLATFORM_FEE"));
            uint16 performanceFee = uint16(vm.envUint("PERFORMANCE_FEE"));

            IILOManager iloManager = IILOManager(getILOManagerDeploymentAddress());
            iloManager.initialize(_initialOwner, _feeTaker, getILOPoolDeploymentAddress(), uniV3Factory, initProjectFee, platformFee, performanceFee);
        }
        vm.stopBroadcast();
    }
}

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

contract ILOPoolScript is CommonScript {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        ILOPool iloPool = new ILOPool{
            salt: salt
        }();

        vm.stopBroadcast();
    }
}

contract TokenFactoryScript is CommonScript {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        TokenFactory tokenFactory = new TokenFactory{
            salt: salt
        }();

        vm.stopBroadcast();
    }
}