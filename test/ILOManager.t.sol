// SPDX-License-Identifier: MIT 

pragma solidity =0.7.6;
pragma abicoder v2;

import "./IntegrationTestBase.sol"; 

contract ILOManagerTest is IntegrationTestBase {
    function setUp() external {
        _setupBase();
    }

    function testInitProject() external {
        iloManager.initProject{value: 1 ether}(IILOManager.InitProjectParams({
                    projectId: "PROJECT_ID2",
                    raiseToken: mockProject().raiseToken,
                    fee: mockProject().fee,
                    initialPoolPriceX96: mockProject().initialPoolPriceX96+1, 
                    launchTime: mockProject().launchTime
                })
            );
    }

    function testInitProjectNoFee() external {
        vm.expectRevert(bytes("FEE"));
        iloManager.initProject(IILOManager.InitProjectParams({
                    projectId: "PROJECT_ID2",
                    raiseToken: mockProject().raiseToken,
                    fee: mockProject().fee,
                    initialPoolPriceX96: mockProject().initialPoolPriceX96+1, 
                    launchTime: mockProject().launchTime
                })
            );
    }

    function testInitProjectOverFee() external {
        vm.expectRevert(bytes("FEE"));
        iloManager.initProject{value: 2 ether}(IILOManager.InitProjectParams({
                    projectId: "PROJECT_ID2",
                    raiseToken: mockProject().raiseToken,
                    fee: mockProject().fee,
                    initialPoolPriceX96: mockProject().initialPoolPriceX96+1, 
                    launchTime: mockProject().launchTime
                })
            );
    }

    function testInitPool() external {
        IILOManager.InitPoolParams memory params = _getInitPoolParams();
        IILOPool iloPool = IILOPool(_initPool(PROJECT_OWNER, params));
        assertEq(address(iloPool.MANAGER()), address(iloManager));
        assertEq(iloPool.RAISE_TOKEN(), USDC);
        assertEq(iloPool.TICK_LOWER(), MIN_TICK_500);
        assertEq(iloPool.TICK_UPPER(), -MIN_TICK_500);
        assertEq(iloPool.SQRT_RATIO_X96(), uint(mockProject().initialPoolPriceX96));
        assertEq(iloPool.name(), "KRYSTAL ILOPool V1");
        assertEq(iloPool.symbol(), "KRYSTAL-ILO-V1");
        assertEq(iloPool.symbol(), "KRYSTAL-ILO-V1");
    }

    function testInitPoolInvalidVestingRecipient() external {
        IILOManager.InitPoolParams memory params = _getInitPoolParams();
        params.vestingConfigs[0].recipient = INVESTOR;
        vm.expectRevert(bytes("VR"));
        IILOPool(_initPool(PROJECT_OWNER, params));

        params = _getInitPoolParams();
        params.vestingConfigs[1].recipient = address(0);
        vm.expectRevert(bytes("VR"));
        IILOPool(_initPool(PROJECT_OWNER, params));
    }

    function testInitPoolNotOwner() external {
        vm.expectRevert(bytes("UA"));
        _initPool(DUMMY_ADDRESS, _getInitPoolParams());
    }

    function testInitPoolWrongInvestorVests() external {
        IILOManager.InitPoolParams memory params = _getInitPoolParams();
        params.vestingConfigs[0].shares = 1;
        vm.expectRevert(bytes("TS"));
        _initPool(PROJECT_OWNER, params);
    }

    function testInitPoolSaleStartAfterEnd() external {
        IILOManager.InitPoolParams memory params = _getInitPoolParams();
        params.start = params.end + 1;
        vm.expectRevert(bytes("PT"));
        _initPool(PROJECT_OWNER, params);
    }

    function testInitPoolSaleStartAfterLaunch() external {
        IILOManager.InitPoolParams memory params = _getInitPoolParams();
        params.start = LAUNCH_START + 1;
        params.end = LAUNCH_START + 2;
        vm.expectRevert(bytes("PT"));
        _initPool(PROJECT_OWNER, params);
    }

    function testInitPoolVestOverlap() external {
        IILOManager.InitPoolParams memory params = _getInitPoolParams();
        params.vestingConfigs[0].schedule[1].start = params.vestingConfigs[0].schedule[0].end - 1;
        vm.expectRevert(bytes("VT"));
        _initPool(PROJECT_OWNER, params);
    }

    function testInitPoolVestStartBeforeLaunch() external {
        IILOManager.InitPoolParams memory params = _getInitPoolParams();
        params.vestingConfigs[0].schedule[0].start = LAUNCH_START - 1;
        vm.expectRevert(bytes("VT"));
        _initPool(PROJECT_OWNER, params);
    }

    function testLaunchBeforeLaunchStart() external {
        IILOManager.InitPoolParams memory params = _getInitPoolParams();
        _initPool(PROJECT_OWNER, params);
        vm.warp(LAUNCH_START-1);
        vm.expectRevert(bytes("LT"));
        vm.prank(PROJECT_OWNER);
        iloManager.launch(PROJECT_ID, SALE_TOKEN);
    }

    function testLaunchWhenPoolLaunchRevert() external {
        IILOManager.InitPoolParams memory params = _getInitPoolParams();
        _initPool(PROJECT_OWNER, params);
        vm.warp(LAUNCH_START+1);
        vm.expectRevert();
        iloManager.launch(PROJECT_ID, SALE_TOKEN);
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
        
        iloManager.setFeeTaker(DUMMY_ADDRESS);
        assertEq(iloManager.FEE_TAKER(), DUMMY_ADDRESS);
    }
}
