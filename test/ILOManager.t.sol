// SPDX-License-Identifier: MIT 

pragma solidity =0.7.6;
pragma abicoder v2;

import "./IntegrationTestBase.sol"; 

contract ILOManagerTest is IntegrationTestBase {
    function setUp() external {
        _setupBase();
    }

    int24 constant MIN_TICK_500 = -887270;

    function testInitPool() external {
        _initPool(PROJECT_OWNER, _getInitPoolParams());
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

    function _getInitPoolParams() internal returns(IILOConfig.InitPoolParams memory) {
        return IILOConfig.InitPoolParams({
            uniV3Pool: projectId,
            tickLower: MIN_TICK_500,
            tickUpper: -MIN_TICK_500,
            hardCap: 100000 ether,
            softCap: 80000 ether,
            maxCapPerUser: 50000 ether,
            start: SALE_START,
            end: SALE_END,
            investorVestConfigs: _getLinearVesting()
        });
    }

    function _initPool(address initializer, IILOConfig.InitPoolParams memory params) internal {
        vm.prank(initializer);
        address iloPoolAddress = iloManager.initILOPool(params);
    }
}
