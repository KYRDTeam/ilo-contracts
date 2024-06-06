// SPDX-License-Identifier: MIT 

pragma solidity =0.7.6;
pragma abicoder v2;

import "./IntegrationTestBase.sol";
import '../src/interfaces/IILOPool.sol';
import '../src/interfaces/IILOWhitelist.sol';


contract ILOPoolTest is IntegrationTestBase {
    address iloPool;
    function setUp() external {
        _setupBase();
        iloPool = _initPool(PROJECT_OWNER, _getInitPoolParams());
    }

    function testBuyNoWhitelist() external {
        vm.prank(DUMMY_ADDRESS);
        IERC20(USDC).approve(iloPool, 1000000000 ether);
        _writeTokenBalance(USDC, DUMMY_ADDRESS, 10 ether);

        vm.expectRevert();
        IILOPool(iloPool).buy(0.1 ether, DUMMY_ADDRESS);
    }

    function testBuyOpenToAll() external {
        vm.prank(PROJECT_OWNER);
        IILOWhitelist(iloPool).setOpenToAll(true);
        assertEq(IILOWhitelist(iloPool).isOpenToAll(), true);

        vm.prank(DUMMY_ADDRESS);
        IERC20(USDC).approve(iloPool, 1000000000 ether);

        _writeTokenBalance(USDC, DUMMY_ADDRESS, 10 ether);

        vm.prank(DUMMY_ADDRESS);
        vm.warp(SALE_START+1);
        IILOPool(iloPool).buy(0.1 ether, DUMMY_ADDRESS);
    }

    function testSetWhiltelist() external {
        vm.prank(PROJECT_OWNER);
        IILOWhitelist(iloPool).setWhitelist(INVESTOR);
        bool whiteListed = IILOWhitelist(iloPool).isWhitelisted(INVESTOR);
        assertEq(whiteListed, true);
    }

    function testSetWhiltelistNotProjectOwner() external {
        vm.expectRevert();
        vm.prank(DUMMY_ADDRESS);
        IILOWhitelist(iloPool).setWhitelist(INVESTOR);
    }

    function testBuyZero() external {
        vm.prank(PROJECT_OWNER);
        IILOWhitelist(iloPool).setWhitelist(INVESTOR);
        vm.expectRevert();
        IILOPool(iloPool).buy(0, INVESTOR);
    }

    function testBuyTooMuch() external {
        vm.prank(PROJECT_OWNER);
        IILOWhitelist(iloPool).setWhitelist(INVESTOR);
        vm.expectRevert();
        IILOPool(iloPool).buy(70000 ether, INVESTOR);
    }

    function testBuyBeforeSale() external {
        _prepareBuy();
        vm.expectRevert();
        _buy(SALE_START-1, 0.1 ether);
    }

    function testBuyAfterSale() external {
        _prepareBuy();
        vm.expectRevert();
        _buy(SALE_END+1, 0.1 ether);
    }

    function testBuy() external {
        _prepareBuy();
        uint256 balanceBefore = IERC20(USDC).balanceOf(iloPool);
        
        (uint256 tokenId, uint128 liquidity, uint256 amountAdded0, uint256 amountAdded1) = _buy(SALE_START+1, 0.1 ether);
        
        uint256 balanceAfter = IERC20(USDC).balanceOf(iloPool);

        assertGt(tokenId, 0);
        assertEq(uint256(liquidity), 40000000000000000);
        assertEq(amountAdded0, 19999999999999999);
        assertEq(amountAdded1, 79999999999999999);
        assertEq(balanceAfter - balanceBefore, 0.1 ether);

        (,,,,,uint128 _liquidity,,) = IILOPool(iloPool).positions(tokenId);
        assertEq(uint256(_liquidity), 40000000000000000);

    }

    function testLaunchFromNonManager() external {
        vm.expectRevert();
        IILOPool(iloPool).launch();
    }

    function testLaunchBeforeSaleEnd() external {
        vm.warp(SALE_END - 1);
        vm.prank(address(iloManager));
        vm.expectRevert();
        IILOPool(iloPool).launch();
    }

    function testLaunchWhenSoftCapFailed() external {
        vm.warp(SALE_END + 1);
        vm.prank(address(iloManager));
        vm.expectRevert();
        IILOPool(iloPool).launch();
    }

    function _launch() internal {
        _prepareBuyFor(INVESTOR);
        _buyFor(INVESTOR, SALE_START+1, 50000 ether);
        _prepareBuyFor(INVESTOR_2);
        _buyFor(INVESTOR_2, SALE_START+1, 40000 ether);
        _writeTokenBalance(SALE_TOKEN, iloPool, 95000 * 4 ether);
        // required saleTokenAmount = 360000000000000000029277
        
        uint256 balanceBefore = IERC20(SALE_TOKEN).balanceOf(PROJECT_OWNER);
        vm.warp(SALE_END + 1);
        vm.prank(address(iloManager));
        IILOPool(iloPool).launch();
        uint256 balanceAfter = IERC20(SALE_TOKEN).balanceOf(PROJECT_OWNER);
        assertEq(balanceAfter - balanceBefore, 19999999999999999970723);

        assertEq(IILOPool(iloPool).balanceOf(DEV_RECIPIENT), 1);
        assertEq(IILOPool(iloPool).balanceOf(TREASURY_RECIPIENT), 1);
        assertEq(IILOPool(iloPool).balanceOf(LIQUIDITY_RECIPIENT), 1);
    }

    function testRefundAfterLaunch() external {
        _launch();
        uint256 tokenId = IILOPool(iloPool).tokenOfOwnerByIndex(INVESTOR, 0);
        vm.expectRevert();
        vm.warp(LAUNCH_START + 86400*7 + 1);
        vm.prank(INVESTOR);
        IILOPool(iloPool).claimRefund(tokenId);
    }

    function testLaunchAfterRefund() external {
        _prepareBuyFor(INVESTOR);
        _buyFor(INVESTOR, SALE_START+1, 50000 ether);
        _prepareBuyFor(INVESTOR_2);
        _buyFor(INVESTOR_2, SALE_START+1, 40000 ether);
        _writeTokenBalance(SALE_TOKEN, iloPool, 95000 * 4 ether);

        vm.startPrank(INVESTOR);
        vm.warp(LAUNCH_START + 86400*7 + 1);
        IILOPool(iloPool).claimRefund(IILOPool(iloPool).tokenOfOwnerByIndex(INVESTOR, 0));
        vm.stopPrank();

        vm.warp(LAUNCH_START + 86400*7 + 1);
        vm.prank(address(iloManager));
        vm.expectRevert();
        IILOPool(iloPool).launch();
    }

    function testRefundBeforeRefundDeadline() external {
        _prepareBuy();
        (uint256 tokenId,,,) = _buy(SALE_START+1, 0.1 ether);

        vm.prank(INVESTOR);
        vm.warp(LAUNCH_START + 86400*7 - 1);
        vm.expectRevert();
        IILOPool(iloPool).claimRefund(tokenId);
    }

    function testRefund() external {
        _prepareBuy();
        (uint256 tokenId,,,) = _buy(SALE_START+1, 0.1 ether);

        uint256 balanceBefore = IERC20(USDC).balanceOf(INVESTOR);

        vm.prank(INVESTOR);
        vm.warp(LAUNCH_START + 86400*7 + 1);
        IILOPool(iloPool).claimRefund(tokenId);

        uint256 balanceAfter = IERC20(USDC).balanceOf(INVESTOR);
        assertEq(balanceAfter - balanceBefore, 0.1 ether);
    }

    function testRefundTwice() external {
        _prepareBuy();
        (uint256 tokenId,,,) = _buy(SALE_START+1, 0.1 ether);
        console.logUint(tokenId);
        vm.prank(INVESTOR);
        vm.warp(LAUNCH_START + 86400*7 + 1);
        IILOPool(iloPool).claimRefund(tokenId);
        
        vm.prank(INVESTOR);
        vm.expectRevert();
        IILOPool(iloPool).claimRefund(tokenId);
    }

    function _buy(uint64 buyTime, uint256 buyAmount) internal returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amountAdded0,
            uint256 amountAdded1
    ) {
        return _buyFor(INVESTOR, buyTime, buyAmount);
    }

    function _prepareBuy() internal {
        _prepareBuyFor(INVESTOR);
    }

    function _prepareBuyFor(address investor) internal {
        vm.prank(PROJECT_OWNER);
        IILOWhitelist(iloPool).setWhitelist(investor);

        vm.prank(investor);
        IERC20(USDC).approve(iloPool, 1000000000 ether);
        
        _writeTokenBalance(USDC, investor, 1000000000 ether);

    }

    function _buyFor(address investor, uint64 buyTime, uint256 buyAmount) internal returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amountAdded0,
            uint256 amountAdded1
    ) {
        vm.warp(buyTime);
        vm.prank(investor);
        return IILOPool(iloPool).buy(buyAmount, investor);
    }

    function testClaim() external {
        _launch();
        uint256 tokenId = IILOPool(iloPool).tokenOfOwnerByIndex(INVESTOR, 0);

        uint256 balance0Before = IERC20(USDC).balanceOf(INVESTOR);
        uint256 balance1Before = IERC20(SALE_TOKEN).balanceOf(INVESTOR);

        vm.prank(INVESTOR);
        vm.warp(VEST_START_0 + 10);
        IILOPool(iloPool).claim(tokenId);

        uint256 balance0After = IERC20(USDC).balanceOf(INVESTOR);
        uint256 balance1After = IERC20(SALE_TOKEN).balanceOf(INVESTOR);

        // int(50000*0.2*0.3*10/86400*10**18)
        assertEq(balance0After - balance0Before, 346874999999999999);
    }
}
