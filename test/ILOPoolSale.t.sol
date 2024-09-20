// SPDX-License-Identifier: MIT

pragma solidity =0.7.6;
pragma abicoder v2;

import { IERC20 } from '@openzeppelin/contracts/token/ERC20/IERC20.sol';

import { IntegrationTestBase, IILOManager, ITokenFactory } from './IntegrationTestBase.sol';
import { ILOPoolSale, IILOPoolSale } from '../src/ILOPoolSale.sol';
import { console } from 'forge-std/console.sol';

contract ILOPoolSaleTest is IntegrationTestBase {
    function setUp() external {
        _setupBase();
    }

    function testName() external {
        ILOPoolSale iloPoolSale = new ILOPoolSale();
        string memory expectedName = 'KRYSTAL ILOPoolSale V3';
        string memory actualName = iloPoolSale.name();
        assertEq(actualName, expectedName);
    }

    function testSymbol() external {
        ILOPoolSale iloPoolSale = new ILOPoolSale();
        string memory expectedSymbol = 'KRYSTAL-ILO-SALE-V3';
        string memory actualSymbol = iloPoolSale.symbol();
        assertEq(actualSymbol, expectedSymbol);
    }

    function testLaunchPoolSaleBeforeSaleEnd() external {
        _prepareLaunch();
        address iloPoolSale = _initPoolSale(
            PROJECT_OWNER,
            _getInitPoolSaleParams()
        );

        vm.prank(PROJECT_OWNER);
        vm.warp(SALE_END - 1);
        vm.expectRevert(bytes('SLT'));
        iloManager.launch(PROJECT_ID, TOKEN);
    }

    function testLaunchInvalidToken() external {
        _prepareLaunch();
        address iloPoolSale = _initPoolSale(
            PROJECT_OWNER,
            _getInitPoolSaleParams()
        );

        vm.prank(PROJECT_OWNER);
        vm.warp(SALE_END - 1);
        vm.expectRevert(bytes('invalid token'));
        iloManager.launch(PROJECT_ID, DUMMY_ADDRESS);
    }

    function testLaunchInvalidSupplyOrSymbol() external {
        _prepareLaunch();
        address iloPool = _initPoolSale(
            PROJECT_OWNER,
            _getInitPoolSaleParams()
        );
        _prepareBuyFor(INVESTOR, iloPool);
        vm.prank(INVESTOR);
        vm.warp(SALE_START + 1);
        IILOPoolSale(iloPool).buy(2_000_000 ether, INVESTOR);

        // create same token with different supply
        vm.prank(PROJECT_OWNER);
        address TOKEN2 = tokenFactory.createStandardERC20Token(
            ITokenFactory.CreateStandardERC20TokenParams({
                name: 'Test Token',
                symbol: 'TTT 2',
                totalSupply: 1_000_000 ether // 1M
            })
        );

        vm.prank(PROJECT_OWNER);
        vm.warp(SALE_END + 1);
        vm.expectRevert('invalid supply');
        iloManager.launch(PROJECT_ID, TOKEN2);

        vm.prank(PROJECT_OWNER);
        TOKEN2 = tokenFactory.createStandardERC20Token(
            ITokenFactory.CreateStandardERC20TokenParams({
                name: 'Test Token',
                symbol: 'TTT 2',
                totalSupply: 100_000_000 ether // 100M
            })
        );
        vm.prank(PROJECT_OWNER);
        vm.warp(SALE_END + 1);
        vm.expectRevert('invalid symbol');
        iloManager.launch(PROJECT_ID, TOKEN2);
    }

    function testBuy() external {
        _initProject(PROJECT_OWNER);
        address iloPool = _initPoolSale(
            PROJECT_OWNER,
            _getInitPoolSaleParams()
        );
        _prepareBuyFor(INVESTOR, iloPool);

        vm.prank(INVESTOR);
        vm.warp(SALE_START + 1);
        vm.expectRevert(bytes('ZA'));
        uint256 tokenId = IILOPoolSale(iloPool).buy(0, INVESTOR);

        vm.prank(INVESTOR);
        vm.warp(SALE_START + 1);
        tokenId = IILOPoolSale(iloPool).buy(1_000_000 ether, INVESTOR);
        IILOPoolSale.Position memory _position = IILOPoolSale(iloPool)
            .positions(tokenId);
        assertEq(_position.raiseAmount, 1_000_000 ether);

        vm.prank(INVESTOR);
        vm.warp(SALE_START + 1);
        uint256 tokenId2 = IILOPoolSale(iloPool).buy(1_000_000 ether, INVESTOR);
        assertEq(tokenId, tokenId2);

        _position = IILOPoolSale(iloPool).positions(tokenId);
        assertEq(_position.raiseAmount, 2_000_000 ether);
    }

    function testBuyOverCap() external {
        _initProject(PROJECT_OWNER);
        address iloPool = _initPoolSale(
            PROJECT_OWNER,
            _getInitPoolSaleParams()
        );
        _prepareBuyFor(INVESTOR, iloPool);
        vm.prank(INVESTOR);
        vm.warp(SALE_START + 1);
        vm.expectRevert(bytes('UC'));
        IILOPoolSale(iloPool).buy(9_000_000 ether, INVESTOR);
    }

    function testBuyOverMaxRaise() external {
        _initProject(PROJECT_OWNER);
        address iloPool = _initPoolSale(
            PROJECT_OWNER,
            _getInitPoolSaleParams()
        );
        _prepareBuyFor(INVESTOR, iloPool);
        vm.prank(INVESTOR);
        vm.warp(SALE_START + 1);
        vm.expectRevert(bytes('MAX_RAISE'));
        IILOPoolSale(iloPool).buy(11_000_000 ether, INVESTOR);
    }

    function testBuyAfterSaleEnd() external {
        _initProject(PROJECT_OWNER);
        address iloPool = _initPoolSale(
            PROJECT_OWNER,
            _getInitPoolSaleParams()
        );
        _prepareBuyFor(INVESTOR, iloPool);
        vm.prank(INVESTOR);
        vm.warp(SALE_END + 1);
        vm.expectRevert(bytes('SLT'));
        IILOPoolSale(iloPool).buy(1_000_000 ether, INVESTOR);
    }

    function testLaunch() external {
        _prepareLaunch();
        address iloPool = _initPoolSale(
            PROJECT_OWNER,
            _getInitPoolSaleParams()
        );
        _prepareBuyFor(INVESTOR, iloPool);
        vm.prank(INVESTOR);
        vm.warp(SALE_START + 1);
        IILOPoolSale(iloPool).buy(2_000_000 ether, INVESTOR);

        vm.prank(PROJECT_OWNER);
        vm.warp(SALE_END + 1);
        iloManager.launch(PROJECT_ID, TOKEN);

        assertEq(
            uint256(iloManager.project(PROJECT_ID).status),
            uint256(IILOManager.ProjectStatus.LAUNCHED)
        );
    }

    function testLaunchBeforeSaleEnd() external {
        _prepareLaunch();
        address iloPool = _initPoolSale(
            PROJECT_OWNER,
            _getInitPoolSaleParams()
        );
        _prepareBuyFor(INVESTOR, iloPool);
        vm.prank(INVESTOR);
        vm.warp(SALE_START + 1);
        IILOPoolSale(iloPool).buy(2_000_000 ether, INVESTOR);

        vm.prank(PROJECT_OWNER);
        vm.warp(SALE_END - 1);
        vm.expectRevert(bytes('SLT'));
        iloManager.launch(PROJECT_ID, TOKEN);
    }

    function testLaunch2PoolSaleWith1PoolFail() external {
        _prepareLaunch();

        address iloPool = _initPoolSale(
            PROJECT_OWNER,
            _getInitPoolSaleParams()
        );

        address iloPool2 = _initPoolSale(
            PROJECT_OWNER,
            _getInitPoolSaleParams()
        );

        _prepareBuyFor(INVESTOR, iloPool);
        vm.prank(INVESTOR);
        vm.warp(SALE_START + 1);
        IILOPoolSale(iloPool).buy(1000 ether, INVESTOR);

        _prepareBuyFor(INVESTOR_2, iloPool2);
        vm.prank(INVESTOR_2);
        vm.warp(SALE_START + 1);
        IILOPoolSale(iloPool2).buy(2_000_000 ether, INVESTOR_2);

        vm.prank(PROJECT_OWNER);
        vm.warp(SALE_END + 1);
        vm.expectRevert(bytes('MIN_RAISE'));
        iloManager.launch(PROJECT_ID, TOKEN);
    }

    function testClaim() external {
        _prepareLaunch();
        address iloPool = _initPoolSale(
            PROJECT_OWNER,
            _getInitPoolSaleParams()
        );
        _prepareBuyFor(INVESTOR, iloPool);
        vm.prank(INVESTOR);
        vm.warp(SALE_START + 1);
        IILOPoolSale(iloPool).buy(2_000_000 ether, INVESTOR);

        vm.prank(PROJECT_OWNER);
        vm.warp(SALE_END + 1);
        iloManager.launch(PROJECT_ID, TOKEN);

        uint256 tokenId = IILOPoolSale(iloPool).tokenOfOwnerByIndex(
            INVESTOR,
            0
        );

        uint256 tokenBalanceBefore = IERC20(TOKEN).balanceOf(INVESTOR);

        vm.prank(INVESTOR);
        vm.warp(VEST_START_0 + 1000);
        (uint256 amount0, uint256 amount1) = IILOPoolSale(iloPool).claim(
            tokenId
        );

        uint256 tokenBalanceAfter = IERC20(TOKEN).balanceOf(INVESTOR);
        // approximate 2m * 0.3 * 0.999 * (1000/86400) = 6937.5 token
        assertEq(
            tokenBalanceAfter - tokenBalanceBefore,
            6937499999999999999999
        ); // in this case, amount1 is token amount
    }

    function testClaimRefund() external {
        _initProject(PROJECT_OWNER);
        address iloPool = _initPoolSale(
            PROJECT_OWNER,
            _getInitPoolSaleParams()
        );

        address iloPool2 = _initPoolSale(
            PROJECT_OWNER,
            _getInitPoolSaleParams()
        );

        _prepareBuyFor(INVESTOR, iloPool);
        vm.prank(INVESTOR);
        vm.warp(SALE_START + 1);
        uint256 tokenId = IILOPoolSale(iloPool).buy(1000 ether, INVESTOR);

        _prepareBuyFor(INVESTOR_2, iloPool2);
        vm.prank(INVESTOR_2);
        vm.warp(SALE_START + 1);
        uint256 tokenId2 = IILOPoolSale(iloPool2).buy(
            2_000_000 ether,
            INVESTOR_2
        );

        vm.prank(INVESTOR);
        vm.warp(SALE_END + 1);
        uint256 refundAmount = IILOPoolSale(iloPool).claimRefund(tokenId);

        assertEq(refundAmount, 1000 ether);
        assertEq(
            uint256(iloManager.project(PROJECT_ID).status),
            uint256(IILOManager.ProjectStatus.CANCELLED)
        );

        vm.prank(INVESTOR_2);
        refundAmount = IILOPoolSale(iloPool2).claimRefund(tokenId2);
        assertEq(refundAmount, 2_000_000 ether);
    }

    function testClaimRefundBeforeSaleEnd() external {
        _initProject(PROJECT_OWNER);
        address iloPool = _initPoolSale(
            PROJECT_OWNER,
            _getInitPoolSaleParams()
        );

        IILOPoolSale.InitParams memory params2 = _getInitPoolSaleParams();
        params2.saleParams.end = SALE_END + 1000; // sale 2 end after sale 1 1000 seconds
        address iloPool2 = _initPoolSale(PROJECT_OWNER, params2);

        _prepareBuyFor(INVESTOR, iloPool);
        vm.prank(INVESTOR);
        vm.warp(SALE_START + 1);
        uint256 tokenId = IILOPoolSale(iloPool).buy(1000 ether, INVESTOR);

        _prepareBuyFor(INVESTOR_2, iloPool2);
        vm.prank(INVESTOR_2);
        vm.warp(SALE_START + 1);
        uint256 tokenId2 = IILOPoolSale(iloPool2).buy(
            2_000_000 ether,
            INVESTOR_2
        );

        vm.prank(INVESTOR);
        vm.warp(SALE_END + 1);
        uint256 refundAmount = IILOPoolSale(iloPool).claimRefund(tokenId);

        assertEq(refundAmount, 1000 ether);
        assertEq(
            uint256(iloManager.project(PROJECT_ID).status),
            uint256(IILOManager.ProjectStatus.CANCELLED)
        );

        vm.prank(INVESTOR_2);
        vm.warp(SALE_END + 1); // sale 1 ended, sale 2 not yet
        refundAmount = IILOPoolSale(iloPool2).claimRefund(tokenId2);
        assertEq(refundAmount, 2_000_000 ether);
    }

    function _prepareBuyFor(address investor, address iloPoolSale) internal {
        vm.prank(PROJECT_OWNER);
        IILOPoolSale(iloPoolSale).setWhiteList(
            _getListAddressFromAddress(investor),
            _getSingleAllocation()
        );

        vm.prank(investor);
        IERC20(USDC).approve(iloPoolSale, 10_000_000_000 ether);

        _writeTokenBalance(USDC, investor, 10_000_000_000 ether);
    }

    function _getListAddressFromAddress(
        address addr
    ) internal pure returns (address[] memory addresses) {
        addresses = new address[](1);
        addresses[0] = addr;
    }

    function _getListAddress()
        internal
        pure
        returns (address[] memory addresses)
    {
        addresses = new address[](3);
        addresses[0] = INVESTOR;
        addresses[1] = INVESTOR_2;
        addresses[2] = DUMMY_ADDRESS;
    }

    function _getListAllocations()
        internal
        pure
        returns (uint256[] memory allocations)
    {
        allocations = new uint256[](3);
        allocations[0] = 10_000_000 ether;
        allocations[1] = 10_000_000 ether;
        allocations[2] = 10_000_000 ether;
    }

    function _getListAllocationsZero()
        internal
        pure
        returns (uint256[] memory allocations)
    {
        allocations = new uint256[](3);
        allocations[0] = 0;
        allocations[1] = 0;
        allocations[2] = 0;
    }

    function _getSingleAllocation()
        internal
        pure
        returns (uint256[] memory allocations)
    {
        allocations = new uint256[](1);
        allocations[0] = 8_000_000 ether;
    }
}
