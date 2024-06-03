// SPDX-License-Identifier: MIT 

pragma solidity =0.7.6;
pragma abicoder v2;

import "forge-std/Test.sol";
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import "../src/ILOManager.sol";

abstract contract IntegrationTestBase is Test {
    using stdStorage for StdStorage;

    address constant MANAGER_OWNER = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address constant FEE_TAKER = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    address constant UNIV3_FACTORY = 0x1F98431c8aD98523631AE4a59f267346ea31F984; // only for eth chain
    address constant WETH9 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // only for eth chain
    uint16 constant PLATFORM_FEE = 10; // 0.1%
    uint16 constant PERFORMANCE_FEE = 1000; // 10%
    

    ILOManager iloManager;

    function _setupBase() internal {
        uint256 mainnetFork = vm.createFork("https://rpc.ankr.com/eth", 19974830);
        vm.selectFork(mainnetFork);

        iloManager = new ILOManager();
        // iloManager.initialize(
        //         MANAGER_OWNER, 
        //         FEE_TAKER,
        //         UNIV3_FACTORY, 
        //         WETH9, 
        //         PLATFORM_FEE,
        //         PERFORMANCE_FEE
        //     );
    }

    function _writeTokenBalance(address token, address who, uint256 amt) internal {
        stdstore
            .target(token)
            .sig(IERC20(token).balanceOf.selector)
            .with_key(who)
            .checked_write(amt);
    }
}