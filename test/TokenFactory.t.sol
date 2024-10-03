// SPDX-License-Identifier: MIT

pragma solidity =0.7.6;
pragma abicoder v2;

import { IntegrationTestBase, ITokenFactory, IERC20 } from './IntegrationTestBase.sol';
import { IUniswapV3Oracle } from '../src/interfaces/IUniswapV3Oracle.sol';
import { PoolAddress } from '@uniswap/v3-periphery/contracts/libraries/PoolAddress.sol';

interface IToken is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
}

interface IWhitelistToken is IToken {
    function whitelistContract() external view returns (address);
}

contract TokenFactoryTest is IntegrationTestBase {
    function setUp() external {
        _setupBase();
    }

    function testCreateStandardERC20Token() external {
        vm.prank(DUMMY_ADDRESS);
        address token = tokenFactory.createStandardERC20Token(
            ITokenFactory.CreateStandardERC20TokenParams({
                name: 'TestToken',
                symbol: 'TT',
                totalSupply: 1000000
            })
        );

        assert(tokenFactory.deployedTokens(token));
        assertEq(IToken(token).totalSupply(), 1000000);
        assertEq(IToken(token).balanceOf(DUMMY_ADDRESS), 1000000);

        assertEq(IToken(token).name(), 'TestToken');
        assertEq(IToken(token).symbol(), 'TT');
    }

    function testCreateWhitelistContracts() external {
        address token;
        address whitelist;
        vm.prank(DUMMY_ADDRESS);
        (token, whitelist) = tokenFactory.createWhitelistContracts(
            ITokenFactory.CreateWhitelistContractsParams({
                name: 'TestToken',
                symbol: 'TT',
                totalSupply: 1000000,
                maxAddressCap: 100,
                quoteToken: USDC,
                lockBuy: true,
                fee: 10000
            })
        );

        assert(tokenFactory.deployedTokens(token));
        assertEq(IToken(token).balanceOf(DUMMY_ADDRESS), 1000000);
        assertEq(IToken(token).totalSupply(), 1000000);
        assertEq(IToken(token).name(), 'TestToken');
        assertEq(IToken(token).symbol(), 'TT');
        assertEq(IWhitelistToken(token).whitelistContract(), whitelist);

        assertEq(IUniswapV3Oracle(whitelist).quoteToken(), USDC);
        assertEq(
            IUniswapV3Oracle(whitelist).pool(),
            PoolAddress.computeAddress(
                UNIV3_FACTORY,
                PoolAddress.getPoolKey(USDC, token, 10000)
            )
        );
    }
}
