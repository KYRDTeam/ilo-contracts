// SPDX-License-Identifier: MIT

pragma solidity =0.7.6;
pragma abicoder v2;

import { IntegrationTestBase, Mock } from './IntegrationTestBase.sol';
import { ILOPool, IILOPool } from '../src/ILOPool.sol';
import { IERC20 } from '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract ILOPoolTest is IntegrationTestBase {
    function setUp() external {
        _setupBase();
    }

    function testNameAndSymbol() external {
        _initProject(PROJECT_OWNER);
        address iloPool = _initPool(PROJECT_OWNER, _getInitPoolParams());
        string memory name = ILOPool(iloPool).name();
        string memory symbol = ILOPool(iloPool).symbol();

        assertEq(name, 'KRYSTAL ILO TTT');
        assertEq(symbol, 'KRYSTAL_ILO_TTT');
    }

    function testClaim() external {
        _prepareLaunch();
        address pool = _initPool(PROJECT_OWNER, _getInitPoolParams());
        IILOPool iloPool = IILOPool(pool);

        vm.prank(PROJECT_OWNER);
        iloManager.launch(PROJECT_ID, TOKEN);

        uint256 tokenBalanceBefore = IERC20(TOKEN).balanceOf(DEV_RECIPIENT);
        uint256 pairTokenBalanceBefore = IERC20(USDC).balanceOf(DEV_RECIPIENT);

        uint256 tokenId = iloPool.tokenOfOwnerByIndex(DEV_RECIPIENT, 0);
        vm.warp(VEST_START_0 + 1000);
        vm.prank(DEV_RECIPIENT);
        (uint256 amount0, uint256 amount1) = iloPool.claim(tokenId);

        uint256 tokenBalanceAfter = IERC20(TOKEN).balanceOf(DEV_RECIPIENT);
        uint256 pairTokenBalanceAfter = IERC20(USDC).balanceOf(DEV_RECIPIENT);

        assertEq(
            tokenBalanceAfter - tokenBalanceBefore,
            TOKEN < USDC ? amount0 : amount1
        );
        assertEq(
            pairTokenBalanceAfter - pairTokenBalanceBefore,
            TOKEN < USDC ? amount1 : amount0
        );

        // for this case, amount0 = amount1
        // approximate
        // 10_000_000 ether (total token amount)
        // mul 0.3 (dev shares)
        // mul 0.3 (vesting config shares)
        // mul 0.999 (1 - platform fee)
        // mul (1000/86400) (time passed)
        // ~~ 10_000_000 ether * 0.3 * 0.3 * 0.999 * (1000/86400) = 10406.25 ether
        // 1 wei is lost due to rounding
        assertEq(amount0, 10406249999999999999999);
    }
}
