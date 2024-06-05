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
        assertEq(iloPool.RAISE_TOKEN(), USDT);
        assertEq(iloPool.SALE_TOKEN(), SALE_TOKEN);
        assertEq(iloPool.TICK_LOWER(), MIN_TICK_500);
        assertEq(iloPool.TICK_UPPER(), -MIN_TICK_500);
        assertEq(uint256(iloPool.PLATFORM_FEE()), 10);
        assertEq(uint256(iloPool.PERFORMANCE_FEE()), 1000);
        assertEq(uint256(iloPool.INVESTOR_SHARES()), 2000);
    }

    function testInitPoolNotOwner() external {
        vm.expectRevert("unauthorized");
        _initPool(0x00000000000000000000000000000000DeaDBeef, _getInitPoolParams());
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

}
