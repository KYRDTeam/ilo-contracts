// SPDX-License-Identifier: MIT 

pragma solidity =0.7.6;
pragma abicoder v2;

import "./IntegrationTestBase.sol"; 

contract ILOManagerTest is IntegrationTestBase {
    function setUp() external {
        _setupBase();
    }

    function testInitPool() external {
        IILOConfig.InitPoolParams memory params = _getInitPoolParams();
        IILOPool iloPool = IILOPool(_initPool(PROJECT_OWNER, params));
        assertEq(iloPool.MANAGER(), address(iloManager));
        assertEq(iloPool.RAISE_TOKEN(), USDC);
        assertEq(iloPool.SALE_TOKEN(), SALE_TOKEN);
        assertEq(iloPool.TICK_LOWER(), MIN_TICK_500);
        assertEq(iloPool.TICK_UPPER(), -MIN_TICK_500);
        assertEq(uint256(iloPool.PLATFORM_FEE()), 10);
        assertEq(uint256(iloPool.PERFORMANCE_FEE()), 1000);
        assertEq(uint256(iloPool.INVESTOR_SHARES()), 2000);
        assertEq(iloPool.name(), "KRYSTAL ILOPool V1");
        assertEq(iloPool.symbol(), "KRYSTAL-ILO-V1");
    }

    function testInitPoolNotOwner() external {
        vm.expectRevert("unauthorized");
        _initPool(DUMMY_ADDRESS, _getInitPoolParams());
    }

    function testInitPoolWrongInvestorVests() external {
        IILOConfig.InitPoolParams memory params = _getInitPoolParams();
        params.investorVestConfigs[0].percentage = 1;
        vm.expectRevert();
        _initPool(PROJECT_OWNER, params);
    }

    function testInitPoolSaleStartAfterEnd() external {
        IILOConfig.InitPoolParams memory params = _getInitPoolParams();
        params.start = params.end + 1;
        vm.expectRevert();
        _initPool(PROJECT_OWNER, params);
    }

    function testInitPoolSaleStartAfterLaunch() external {
        IILOConfig.InitPoolParams memory params = _getInitPoolParams();
        params.start = LAUNCH_START + 1;
        params.end = LAUNCH_START + 2;
        vm.expectRevert();
        _initPool(PROJECT_OWNER, params);
    }

    function testInitPoolVestOverlap() external {
        IILOConfig.InitPoolParams memory params = _getInitPoolParams();
        params.investorVestConfigs[1].start = params.investorVestConfigs[0].end - 1;
        vm.expectRevert();
        _initPool(PROJECT_OWNER, params);
    }

    function testInitPoolVestStartBeforeLaunch() external {
        IILOConfig.InitPoolParams memory params = _getInitPoolParams();
        params.investorVestConfigs[0].start = LAUNCH_START - 1;
        vm.expectRevert();
        _initPool(PROJECT_OWNER, params);
    }

    function testLaunchBeforeLaunchStart() external {
        IILOConfig.InitPoolParams memory params = _getInitPoolParams();
        _initPool(PROJECT_OWNER, params);
        vm.warp(LAUNCH_START-1);
        vm.expectRevert();
        iloManager.launch(projectId);
    }

    function testLaunchWhenPoolLaunchRevert() external {
        IILOConfig.InitPoolParams memory params = _getInitPoolParams();
        _initPool(PROJECT_OWNER, params);
        vm.warp(LAUNCH_START+1);
        vm.expectRevert();
        iloManager.launch(projectId);
    }

    function testSetStorage() external {
        vm.startPrank(MANAGER_OWNER);
        iloManager.setPlatformFee(50);
        assertEq(uint256(iloManager.PLATFORM_FEE()), 50);
        
        iloManager.setPerformanceFee(5000);
        assertEq(uint256(iloManager.PERFORMANCE_FEE()), 5000);
        
        iloManager.setPerformanceFee(5000);
        assertEq(uint256(iloManager.PERFORMANCE_FEE()), 5000);

        iloManager.setILOPoolImplementation(DUMMY_ADDRESS);
        assertEq(iloManager.ILO_POOL_IMPLEMENTATION(), DUMMY_ADDRESS);
    }
}
