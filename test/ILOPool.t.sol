// SPDX-License-Identifier: MIT 

pragma solidity =0.7.6;
pragma abicoder v2;

import "./IntegrationTestBase.sol";
import '../src/interfaces/IILOPool.sol';
import '../src/interfaces/IILOWhitelist.sol';
import '../src/interfaces/IILOVest.sol';


contract ILOPoolTest is IntegrationTestBase {
    address iloPool;
    function setUp() external {
        _setupBase();
        iloPool = _initPool(PROJECT_OWNER, _getInitPoolParams());
    }

    function testBuyNoWhitelist() external {
        vm.prank(DUMMY_ADDRESS);
        IERC20(USDC).approve(iloPool, 1000000000 ether);
        vm.warp(SALE_START+1);
        _writeTokenBalance(USDC, DUMMY_ADDRESS, 10 ether);

        vm.expectRevert(bytes("UC"));
        IILOPool(iloPool).buy(0.1 ether, DUMMY_ADDRESS);
    }

    function testBuyOpenToAll() external {
        vm.prank(PROJECT_OWNER);
        vm.warp(SALE_START-1);
        IILOWhitelist(iloPool).setPublicAllocation(100000 ether);
        assertEq(IILOWhitelist(iloPool).allocation(DUMMY_ADDRESS), 100000 ether);

        vm.prank(DUMMY_ADDRESS);
        IERC20(USDC).approve(iloPool, 1000000000 ether);

        _writeTokenBalance(USDC, DUMMY_ADDRESS, 10 ether);

        vm.prank(DUMMY_ADDRESS);
        vm.warp(SALE_START+1);
        IILOPool(iloPool).buy(0.1 ether, DUMMY_ADDRESS);
    }

    function testWhiltelist() external {
        vm.startPrank(PROJECT_OWNER);
        
        vm.warp(SALE_START-1);
        IILOWhitelist(iloPool).setWhiteList(_getListAddress(), _getListAllocations());
        assertEq(IILOWhitelist(iloPool).allocation(INVESTOR), 60000 ether);
        assertEq(IILOWhitelist(iloPool).allocation(INVESTOR_2), 60000 ether);
        assertEq(IILOWhitelist(iloPool).allocation(DUMMY_ADDRESS), 60000 ether);
        
        vm.warp(SALE_START-1);
        IILOWhitelist(iloPool).setWhiteList(_getListAddress(), _getListAllocationsZero());
        assertEq(IILOWhitelist(iloPool).allocation(DUMMY_ADDRESS), 0);
        assertEq(IILOWhitelist(iloPool).allocation(INVESTOR), 0);
        assertEq(IILOWhitelist(iloPool).allocation(INVESTOR_2), 0);
    }

    function _getListAddress() internal pure returns (address[] memory addresses) {
        addresses = new address[](3);
        addresses[0] = INVESTOR;
        addresses[1] = INVESTOR_2;
        addresses[2] = DUMMY_ADDRESS;
    }

    function _getListAllocations() internal pure returns(uint256[] memory allocations) {
        allocations = new uint256[](3);
        allocations[0] = 60000 ether;
        allocations[1] = 60000 ether;
        allocations[2] = 60000 ether;
    }

    function _getListAllocationsZero() internal pure returns(uint256[] memory allocations) {
        allocations = new uint256[](3);
        allocations[0] = 0;
        allocations[1] = 0;
        allocations[2] = 0;
    }

    function _getSingleAllocation() internal pure returns(uint256[] memory allocations) {
        allocations = new uint256[](1);
        allocations[0] = 60000 ether;
    }

    function _getListAddressFromAddress(address addr) internal pure returns (address[] memory addresses) {
        addresses = new address[](1);
        addresses[0] = addr;
    }

    function testSetWhiltelistNotProjectOwner() external {
        vm.expectRevert(bytes("UA"));
        vm.prank(DUMMY_ADDRESS);
        vm.warp(SALE_START-1);
        IILOWhitelist(iloPool).setWhiteList(_getListAddress(), _getListAllocations());
    }

    function testBuyZero() external {
        _prepareBuy();
        vm.expectRevert(bytes("ZA"));
        _buyFor(INVESTOR, SALE_START+1, 0);
    }

    function testBuyTooMuch() external {
        _prepareBuy();
        vm.expectRevert(bytes("UC"));
        _buyFor(INVESTOR, SALE_START+1, 70000 ether);
    }

    function testBuyBeforeSale() external {
        _prepareBuy();
        vm.expectRevert(bytes("SLT"));
        _buy(SALE_START-1, 0.1 ether);
    }

    function testBuyAfterSale() external {
        _prepareBuy();
        vm.expectRevert(bytes("SLT"));
        _buy(SALE_END+1, 0.1 ether);
    }

    function testBuy() external {
        _prepareBuy();
        uint256 balanceBefore = IERC20(USDC).balanceOf(iloPool);

        (uint256 tokenId) = _buy(SALE_START+1, 0.1 ether);
        uint256 balanceAfter = IERC20(USDC).balanceOf(iloPool);

        assertGt(tokenId, 0);
        assertEq(balanceAfter - balanceBefore, 0.1 ether);

        (,uint256 raiseAmount,,) = IILOPool(iloPool).positions(tokenId);
        assertEq(raiseAmount, 0.1 ether);

    }

    function testLaunchFromNonManager() external {
        vm.expectRevert(bytes("UA"));
        IILOPool(iloPool).launch(PROJECT_ID, UNIV3_POOL_ADDRESS, poolKey);
    }

    function testLaunchWhenSoftCapFailed() external {
        vm.warp(LAUNCH_START + 1);
        vm.expectRevert(bytes("SC"));
        vm.prank(address(PROJECT_OWNER));
        iloManager.launch(PROJECT_ID, SALE_TOKEN);
    }

    function _launch() internal {
        _prepareBuyFor(INVESTOR);
        _buyFor(INVESTOR, SALE_START+1, 49000 ether);
        _prepareBuyFor(INVESTOR_2);
        _buyFor(INVESTOR_2, SALE_START+1, 40000 ether);
        _buyFor(INVESTOR, SALE_START+1, 1000 ether);
        _writeTokenBalance(SALE_TOKEN, PROJECT_OWNER, 95000 * 4 ether);
        
        vm.prank(address(PROJECT_OWNER));
        // IERC20 approve for iloPool
        IERC20(SALE_TOKEN).approve(address(iloManager), type(uint256).max);

        uint256 balanceBefore = IERC20(SALE_TOKEN).balanceOf(PROJECT_OWNER);
        vm.warp(LAUNCH_START + 1);
        vm.prank(address(PROJECT_OWNER));
        iloManager.launch(PROJECT_ID, SALE_TOKEN);
        uint256 balanceAfter = IERC20(SALE_TOKEN).balanceOf(PROJECT_OWNER);
        assertEq(balanceBefore - balanceAfter, 360000000000000000029277);

        assertEq(IILOPool(iloPool).balanceOf(DEV_RECIPIENT), 1);
        assertEq(IILOPool(iloPool).balanceOf(TREASURY_RECIPIENT), 1);
        assertEq(IILOPool(iloPool).balanceOf(LIQUIDITY_RECIPIENT), 1);
    }

    function testRefundAfterLaunch() external {
        _launch();
        uint256 tokenId = IILOPool(iloPool).tokenOfOwnerByIndex(INVESTOR, 0);
        vm.expectRevert(bytes("PL"));
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
        vm.expectRevert(bytes("IRF"));
        vm.prank(address(PROJECT_OWNER));
        iloManager.launch(PROJECT_ID, SALE_TOKEN);
    }

    function testRefundBeforeRefundDeadline() external {
        _prepareBuyFor(INVESTOR);
        uint256 tokenId = _buy(SALE_START+1, 60000 ether);
        _prepareBuyFor(INVESTOR_2);
        _buyFor(INVESTOR_2,SALE_START+1, 30000 ether);

        vm.prank(INVESTOR);
        vm.warp(LAUNCH_START + 86400*7 - 1);
        vm.expectRevert(bytes("RFT"));
        IILOPool(iloPool).claimRefund(tokenId);
    }

    function testRefund() external {
        _prepareBuy();
        uint256 tokenId = _buy(SALE_START+1, 0.1 ether);

        uint256 balanceBefore = IERC20(USDC).balanceOf(INVESTOR);

        vm.prank(INVESTOR);
        vm.warp(LAUNCH_START + 86400*7 + 1);
        IILOPool(iloPool).claimRefund(tokenId);

        uint256 balanceAfter = IERC20(USDC).balanceOf(INVESTOR);
        assertEq(balanceAfter - balanceBefore, 0.1 ether);
    }

    function testRefundTwice() external {
        _prepareBuy();
        uint256 tokenId = _buy(SALE_START+1, 0.1 ether);
        console.logUint(tokenId);
        vm.prank(INVESTOR);
        vm.warp(LAUNCH_START + 86400*7 + 1);
        IILOPool(iloPool).claimRefund(tokenId);

        vm.prank(INVESTOR);
        vm.expectRevert(bytes("ERC721: operator query for nonexistent token"));
        IILOPool(iloPool).claimRefund(tokenId);
    }

    function _buy(uint64 buyTime, uint256 buyAmount) internal returns (
            uint256 tokenId
    ) {
        return _buyFor(INVESTOR, buyTime, buyAmount);
    }

    function _prepareBuy() internal {
        _prepareBuyFor(INVESTOR);
    }

    function _prepareBuyFor(address investor) internal {
        vm.prank(PROJECT_OWNER);
        vm.warp(SALE_START-1);
        IILOWhitelist(iloPool).setWhiteList(_getListAddressFromAddress(investor), _getSingleAllocation());

        vm.prank(investor);
        IERC20(USDC).approve(iloPool, 1000000000 ether);

        _writeTokenBalance(USDC, investor, 1000000000 ether);

    }

    function _buyFor(address investor, uint64 buyTime, uint256 buyAmount) internal returns (
            uint256 tokenId
    ) {
        vm.warp(buyTime);
        vm.prank(investor);
        return IILOPool(iloPool).buy(buyAmount, investor);
    }

    function testClaim() external {
        _launch();
        vm.warp(VEST_START_0 + 10);
        uint256 tokenId = IILOPool(iloPool).tokenOfOwnerByIndex(INVESTOR, 0);

        (uint128 unlockedLiquidity, uint128 claimedLiquidity) = IILOVest(iloPool).vestingStatus(tokenId);
        assertEq(uint256(unlockedLiquidity), 694444444444444444);
        assertEq(uint256(claimedLiquidity), 0);

        uint256 balance0Before = IERC20(USDC).balanceOf(INVESTOR);

        vm.prank(INVESTOR);
        IILOPool(iloPool).claim(tokenId);

        uint256 balance0After = IERC20(USDC).balanceOf(INVESTOR);

        // int(50000*0.2*0.3*10/86400*10**18)
        assertEq(balance0After - balance0Before, 346874999999999999);

        vm.warp(VEST_START_1 + 100);

        (unlockedLiquidity, claimedLiquidity) = IILOVest(iloPool).vestingStatus(tokenId);

        assertEq(uint256(unlockedLiquidity), 6016203703703703704355);
        assertEq(uint256(claimedLiquidity), 694444444444444444);
    }
}
