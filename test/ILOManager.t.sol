// SPDX-License-Identifier: MIT

pragma solidity =0.7.6;
pragma abicoder v2;

import { IntegrationTestBase, Mock } from './IntegrationTestBase.sol';
import { IILOManager } from '../src/interfaces/IILOManager.sol';
import { IILOPool } from '../src/interfaces/IILOPool.sol';
import { IILOPoolSale, IILOPoolBase } from '../src/interfaces/IILOPoolSale.sol';
import { IERC20 } from '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract ILOManagerTest is IntegrationTestBase {
    function setUp() external {
        _setupBase();
    }

    function testInitProject() external {
        _initProject(PROJECT_OWNER);

        IILOManager.Project memory _project = iloManager.project(PROJECT_ID);
        assertEq(_project.projectId, PROJECT_ID);
        assertEq(_project.admin, PROJECT_OWNER);
        assertEq(_project.pairToken, USDC);
        assertEq(uint256(_project.fee), FEE);
        assertEq(uint256(_project.initialPoolPriceX96), INIT_SQRT_PRICE_X96);
        assertEq(uint256(_project.nonce), 0);
    }

    function testInitProjectNoFee() external {
        hoax(PROJECT_OWNER);
        vm.expectRevert(bytes('FEE'));
        iloManager.initProject(
            IILOManager.InitProjectParams({
                projectId: PROJECT_ID,
                pairToken: USDC,
                fee: FEE,
                initialPoolPriceX96: INIT_SQRT_PRICE_X96
            })
        );
    }

    function testInitProjectOverFee() external {
        hoax(PROJECT_OWNER);
        vm.expectRevert(bytes('FEE'));
        iloManager.initProject{ value: 2 ether }(
            IILOManager.InitProjectParams({
                projectId: PROJECT_ID,
                pairToken: USDC,
                fee: FEE,
                initialPoolPriceX96: INIT_SQRT_PRICE_X96
            })
        );
    }

    function testInitPool() external {
        _initProject(PROJECT_OWNER);
        IILOPoolBase.InitPoolParams memory params = _getInitPoolParams();
        IILOPool iloPool = IILOPool(_initPool(PROJECT_OWNER, params));
        assertEq(address(iloPool.MANAGER()), address(iloManager));
        assertEq(iloPool.PAIR_TOKEN(), USDC);
        assertEq(iloPool.TICK_LOWER(), MIN_TICK_10000);
        assertEq(iloPool.TICK_UPPER(), -MIN_TICK_10000);
        assertEq(iloPool.name(), 'KRYSTAL ILOPool V3');
        assertEq(iloPool.symbol(), 'KRYSTAL-ILO-V3');
    }

    function testInitPoolInvalidVestingRecipient() external {
        _initProject(PROJECT_OWNER);
        IILOPoolBase.InitPoolParams memory params = _getInitPoolParams();
        params.vestingConfigs[0].recipient = address(0);
        vm.expectRevert(bytes('VR'));
        IILOPool(_initPool(PROJECT_OWNER, params));
    }

    function testInitPoolSale() external {
        _initProject(PROJECT_OWNER);
        address iloPoolSale = _initPoolSale(
            PROJECT_OWNER,
            _getInitPoolSaleParams()
        );
        IILOPoolSale poolSale = IILOPoolSale(iloPoolSale);
        assertEq(uint256(poolSale.SALE_START()), uint256(SALE_START));
        assertEq(uint256(poolSale.SALE_END()), uint256(SALE_END));
        assertEq(uint256(poolSale.MIN_RAISE()), uint256(100000 ether));
        assertEq(uint256(poolSale.MAX_RAISE()), uint256(10000000 ether));
        assertEq(int256(poolSale.TICK_LOWER()), int256(-10000));
        assertEq(int256(poolSale.TICK_UPPER()), int256(-MIN_TICK_10000));
    }

    function testInitPoolNotOwner() external {
        _initProject(PROJECT_OWNER);
        vm.expectRevert(bytes('UA'));
        _initPool(DUMMY_ADDRESS, _getInitPoolParams());
    }

    function testInitPoolWrongInvestorVests() external {
        _initProject(PROJECT_OWNER);
        IILOPoolBase.InitPoolParams memory params = _getInitPoolParams();
        params.vestingConfigs[0].shares = 1;
        vm.expectRevert(bytes('TS'));
        _initPool(PROJECT_OWNER, params);
    }

    function testRemovePool() external {
        _initProject(PROJECT_OWNER);
        address pool1 = _initPool(PROJECT_OWNER, _getInitPoolParams());
        address pool2 = _initPool(PROJECT_OWNER, _getInitPoolParams());
        vm.prank(PROJECT_OWNER);
        iloManager.removePool(PROJECT_ID, pool1);
        assertEq(IILOPool(pool1).CANCELLED(), true);
    }

    function testRemovePoolTwice() external {
        _initProject(PROJECT_OWNER);
        address pool1 = _initPool(PROJECT_OWNER, _getInitPoolParams());
        address pool2 = _initPool(PROJECT_OWNER, _getInitPoolParams());
        vm.prank(PROJECT_OWNER);
        iloManager.removePool(PROJECT_ID, pool1);
        assertEq(IILOPool(pool1).CANCELLED(), true);

        vm.prank(PROJECT_OWNER);
        vm.expectRevert(bytes('NP'));
        iloManager.removePool(PROJECT_ID, pool1);
    }

    function testRemovePoolSale() external {
        _initProject(PROJECT_OWNER);
        address poolSale1 = _initPoolSale(
            PROJECT_OWNER,
            _getInitPoolSaleParams()
        );
        address poolSale2 = _initPoolSale(
            PROJECT_OWNER,
            _getInitPoolSaleParams()
        );
        vm.prank(PROJECT_OWNER);
        vm.warp(SALE_START - 1);
        iloManager.removePool(PROJECT_ID, poolSale1);
        assertEq(IILOPoolSale(poolSale1).CANCELLED(), true);
    }

    function testRemovePoolSaleAfterSaleStart() external {
        _initProject(PROJECT_OWNER);
        address poolSale1 = _initPoolSale(
            PROJECT_OWNER,
            _getInitPoolSaleParams()
        );
        address poolSale2 = _initPoolSale(
            PROJECT_OWNER,
            _getInitPoolSaleParams()
        );
        vm.prank(PROJECT_OWNER);
        vm.warp(SALE_START + 1);
        vm.expectRevert(bytes('SLT'));
        iloManager.removePool(PROJECT_ID, poolSale1);
        assertEq(IILOPoolSale(poolSale1).CANCELLED(), false);
    }

    function testTransferProject() external {
        _initProject(PROJECT_OWNER);
        vm.prank(PROJECT_OWNER);
        iloManager.transferAdminProject(DUMMY_ADDRESS, PROJECT_ID);
        IILOManager.Project memory _project = iloManager.project(PROJECT_ID);
        assertEq(_project.admin, DUMMY_ADDRESS);
    }

    function testTransferProjectNonAdmin() external {
        _initProject(PROJECT_OWNER);
        vm.prank(DUMMY_ADDRESS);
        vm.expectRevert(bytes('UA'));
        iloManager.transferAdminProject(DUMMY_ADDRESS, PROJECT_ID);
    }

    function testCancelProject() external {
        _initProject(PROJECT_OWNER);
        vm.prank(PROJECT_OWNER);
        iloManager.cancelProject(PROJECT_ID);
        IILOManager.Project memory _project = iloManager.project(PROJECT_ID);
        assertEq(
            uint256(_project.status),
            uint256(IILOManager.ProjectStatus.CANCELLED)
        );
    }

    function testCancelProjectTwice() external {
        _initProject(PROJECT_OWNER);
        vm.prank(PROJECT_OWNER);
        iloManager.cancelProject(PROJECT_ID);
        IILOManager.Project memory _project = iloManager.project(PROJECT_ID);
        assertEq(
            uint256(_project.status),
            uint256(IILOManager.ProjectStatus.CANCELLED)
        );
        vm.prank(PROJECT_OWNER);
        vm.expectRevert(bytes('NA'));
        iloManager.cancelProject(PROJECT_ID);
    }

    function testSetFeesForProject() external {
        _initProject(PROJECT_OWNER);
        vm.prank(MANAGER_OWNER);
        iloManager.setFeesForProject(PROJECT_ID, 200, 300);
        IILOManager.Project memory _project = iloManager.project(PROJECT_ID);
        assertEq(uint256(_project.platformFee), 200);
        assertEq(uint256(_project.performanceFee), 300);
    }

    function testSetInitProjectFee() external {
        _initProject(PROJECT_OWNER);
        vm.prank(MANAGER_OWNER);
        iloManager.setInitProjectFee(200);
        assertEq(uint256(iloManager.INIT_PROJECT_FEE()), 200);
    }

    function testSetImplentations() external {
        vm.prank(MANAGER_OWNER);
        iloManager.setILOPoolImplementation(DUMMY_ADDRESS);
        assertEq(iloManager.ILO_POOL_IMPLEMENTATION(), DUMMY_ADDRESS);

        vm.prank(MANAGER_OWNER);
        iloManager.setILOSalePoolImplementation(DUMMY_ADDRESS_2);
        assertEq(iloManager.ILO_POOL_SALE_IMPLEMENTATION(), DUMMY_ADDRESS_2);
    }

    // function testInitPoolSaleStartAfterEnd() external {
    //     _initProject(PROJECT_OWNER);
    //     IILOPoolBase.InitPoolParams memory params = _getInitPoolParams();
    //     params.start = params.end + 1;
    //     vm.expectRevert(bytes('PT'));
    //     _initPool(PROJECT_OWNER, params);
    // }

    // function testInitPoolVestOverlap() external {
    //     IILOPoolBase.InitPoolParams memory params = _getInitPoolParams();
    //     params.vestingConfigs[0].schedule[1].start =
    //         params.vestingConfigs[0].schedule[0].end -
    //         1;
    //     vm.expectRevert(bytes('VT'));
    //     _initPool(PROJECT_OWNER, params);
    // }

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

    function testLaunchSinglePool() external {
        _prepareLaunch();

        IILOPoolBase.InitPoolParams memory params = _getInitPoolParams();
        address pool = _initPool(PROJECT_OWNER, params);
        IILOPool iloPool = IILOPool(pool);

        uint256 tokenBalanceBefore = IERC20(TOKEN).balanceOf(PROJECT_OWNER);
        uint256 pairTokenBalanceBefore = IERC20(USDC).balanceOf(PROJECT_OWNER);

        vm.prank(PROJECT_OWNER);
        iloManager.launch(PROJECT_ID, TOKEN);

        uint256 tokenBalanceAfter = IERC20(TOKEN).balanceOf(PROJECT_OWNER);
        uint256 pairTokenBalanceAfter = IERC20(USDC).balanceOf(PROJECT_OWNER);

        assertEq(
            tokenBalanceBefore - tokenBalanceAfter,
            params.baseParams.tokenAmount
        );

        IILOManager.Project memory _project = iloManager.project(PROJECT_ID);
        (
            uint128 liquidity,
            uint256 pairTokenAmount
        ) = _getLiquidityAndPairTokenAmount(
                TOKEN,
                USDC,
                params.baseParams.tokenAmount,
                _project.initialPoolPriceX96,
                params.baseParams.tickLower,
                params.baseParams.tickUpper
            );

        assertEq(
            pairTokenBalanceBefore - pairTokenBalanceAfter,
            pairTokenAmount
        );

        assertEq(iloPool.balanceOf(TREASURY_RECIPIENT), 1);
        assertEq(iloPool.balanceOf(DEV_RECIPIENT), 1);
        assertEq(iloPool.balanceOf(LIQUIDITY_RECIPIENT), 1);
    }
}
