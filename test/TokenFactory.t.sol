// SPDX-License-Identifier: MIT

pragma solidity =0.7.6;
pragma abicoder v2;

import { IntegrationTestBase, ITokenFactory, IERC20 } from './IntegrationTestBase.sol';
import { IOracleWhitelist } from '../src/interfaces/IOracleWhitelist.sol';
import { PoolAddress } from '@uniswap/v3-periphery/contracts/libraries/PoolAddress.sol';
import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';

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
        assertEq(Ownable(token).owner(), DUMMY_ADDRESS);
        assertEq(IToken(token).balanceOf(DUMMY_ADDRESS), 1000000);
        assertEq(IToken(token).totalSupply(), 1000000);
        assertEq(IToken(token).name(), 'TestToken');
        assertEq(IToken(token).symbol(), 'TT');
        assertEq(IWhitelistToken(token).whitelistContract(), whitelist);

        assertEq(Ownable(whitelist).owner(), DUMMY_ADDRESS);
        assertEq(IOracleWhitelist(whitelist).quoteToken(), USDC);
        assertEq(
            IOracleWhitelist(whitelist).pool(),
            PoolAddress.computeAddress(
                UNIV3_FACTORY,
                PoolAddress.getPoolKey(USDC, token, 10000)
            )
        );
    }
}
