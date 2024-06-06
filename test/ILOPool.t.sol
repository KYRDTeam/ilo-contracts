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
        vm.expectRevert();
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

    function testBuyBeforeSale() external {
        _prepairBuy();
        vm.expectRevert();
        _buy(SALE_START-1, 0.1 ether);
    }

    function testBuyAfterSale() external {
        _prepairBuy();
        vm.expectRevert();
        _buy(SALE_END+1, 0.1 ether);
    }

    function testBuy() external {
        _prepairBuy();
        uint256 balanceBefore = IERC20(USDC).balanceOf(iloPool);
        
        (uint256 tokenId, uint128 liquidity, uint256 amountAdded0, uint256 amountAdded1) = _buy(SALE_START+1, 0.1 ether);
        
        uint256 balanceAfter = IERC20(USDC).balanceOf(iloPool);

        assertGt(tokenId, 0);
        assertEq(uint256(liquidity), 40000000000000000);
        assertEq(amountAdded0, 79999999999999999);
        assertEq(amountAdded1, 19999999999999999);
        assertEq(balanceAfter - balanceBefore, 0.1 ether);

        (,,,,,uint128 _liquidity,,) = IILOPool(iloPool).positions(tokenId);
        assertEq(uint256(_liquidity), 40000000000000000);

    }

    function _buy(uint64 buyTime, uint256 buyAmount) internal returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amountAdded0,
            uint256 amountAdded1
    ) {
        vm.warp(buyTime);
        vm.prank(INVESTOR);
        return IILOPool(iloPool).buy(buyAmount, INVESTOR);
    }

    function _prepairBuy() internal {
        vm.prank(PROJECT_OWNER);
        IILOWhitelist(iloPool).setWhitelist(INVESTOR);

        vm.prank(INVESTOR);
        IERC20(USDC).approve(iloPool, 1000000000 ether);
        
        _writeTokenBalance(USDC, INVESTOR, 1000000000 ether);
    }

    function testRefundBeforeRefundDeadline() external {
        _prepairBuy();
        (uint256 tokenId,,,) = _buy(SALE_START+1, 0.1 ether);
        vm.prank(INVESTOR);

        vm.warp(LAUNCH_START + 86400*7 - 1);
        vm.expectRevert();
        IILOPool(iloPool).claimRefund(tokenId);
    }

    function testRefund() external {
        _prepairBuy();
        (uint256 tokenId,,,) = _buy(SALE_START+1, 0.1 ether);

        uint256 balanceBefore = IERC20(USDC).balanceOf(INVESTOR);

        vm.prank(INVESTOR);
        vm.warp(LAUNCH_START + 86400*7 + 1);
        IILOPool(iloPool).claimRefund(tokenId);

        uint256 balanceAfter = IERC20(USDC).balanceOf(INVESTOR);
        assertEq(balanceAfter - balanceBefore, 0.1 ether);
    }

    function testRefundTwice() external {
        _prepairBuy();
        (uint256 tokenId,,,) = _buy(SALE_START+1, 0.1 ether);
        console.logUint(tokenId);
        vm.prank(INVESTOR);
        vm.warp(LAUNCH_START + 86400*7 + 1);
        IILOPool(iloPool).claimRefund(tokenId);
        
        vm.prank(INVESTOR);
        vm.expectRevert();
        IILOPool(iloPool).claimRefund(tokenId);
    }

}