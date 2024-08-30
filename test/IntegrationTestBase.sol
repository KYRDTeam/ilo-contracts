// SPDX-License-Identifier: MIT

pragma solidity =0.7.6;
pragma abicoder v2;

import { Test } from 'forge-std/Test.sol';
import { stdStorage, StdStorage } from 'forge-std/StdStorage.sol';
import { IERC20 } from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import { TickMath } from '@uniswap/v3-core/contracts/libraries/TickMath.sol';

import { ILOManager, IILOManager } from '../src/ILOManager.sol';
import { ILOPool } from '../src/ILOPool.sol';
import { ILOPoolSale } from '../src/ILOPoolSale.sol';
import { Mock } from './Mock.t.sol';
import { PoolAddress } from '../src/libraries/PoolAddress.sol';
import { IILOPoolBase } from '../src/interfaces/IILOPoolBase.sol';
import { IILOPoolSale } from '../src/interfaces/IILOPoolSale.sol';
import { TokenFactory, ITokenFactory } from '../src/TokenFactory.sol';
import { LiquidityAmounts } from '../src/libraries/LiquidityAmounts.sol';

abstract contract IntegrationTestBase is Mock, Test {
    using stdStorage for StdStorage;

    address public constant MANAGER_OWNER =
        0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266; // anvil#1
    address public constant FEE_TAKER =
        0x70997970C51812dc3A010C7d01b50e0d17dc79C8; // anvil#2
    address public constant UNIV3_FACTORY =
        0x1F98431c8aD98523631AE4a59f267346ea31F984; // only for eth chain
    address public constant WETH9 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // only for eth chain
    uint16 public constant PLATFORM_FEE = 10; // 0.1%
    uint16 public constant PERFORMANCE_FEE = 1000; // 10%
    int24 public constant MIN_TICK_10000 = -880000;
    uint24 public constant FEE = 10000; // 1%
    uint160 public constant INIT_SQRT_PRICE_X96 = 2 ** 96;
    string public constant PROJECT_ID = 'PROJECT_ID';

    PoolAddress.PoolKey public poolKey;
    address public UNIV3_POOL_ADDRESS;

    IILOManager public iloManager;
    TokenFactory public tokenFactory;

    function _setupBase() internal {
        uint256 mainnetFork = vm.createFork(
            'https://rpc.ankr.com/eth',
            20024256
        );
        vm.selectFork(mainnetFork);

        vm.startBroadcast(MANAGER_OWNER);
        ILOPool iloPoolImplementation = new ILOPool{ salt: 'salt_salt_salt' }();
        ILOPoolSale iloPoolSaleImplementation = new ILOPoolSale{
            salt: 'salt_salt_salt'
        }();

        iloManager = IILOManager(new ILOManager{ salt: 'salt_salt_salt' }());
        iloManager.initialize(
            MANAGER_OWNER,
            FEE_TAKER,
            address(iloPoolImplementation),
            address(iloPoolSaleImplementation),
            UNIV3_FACTORY,
            1 ether,
            PLATFORM_FEE,
            PERFORMANCE_FEE
        );
        tokenFactory = new TokenFactory();
        tokenFactory.initialize(MANAGER_OWNER, UNIV3_FACTORY);
        vm.stopBroadcast();

        vm.startBroadcast(PROJECT_OWNER);
        TOKEN = tokenFactory.createStandardERC20Token(
            ITokenFactory.CreateStandardERC20TokenParams({
                name: 'Test Token',
                symbol: 'TTT',
                totalSupply: 100000000 * 10 ** 18 // 100M
            })
        );
        vm.stopBroadcast();
        // poolKey = PoolAddress.getPoolKey(USDC, TOKEN, 500);
        // UNIV3_POOL_ADDRESS = PoolAddress.computeAddress(UNIV3_FACTORY, poolKey);

        // hoax(PROJECT_OWNER);
        // iloManager.initProject{ value: 1 ether }(
        //     IILOManager.InitProjectParams({
        //         projectId: PROJECT_ID,
        //         raiseToken: mockProject().raiseToken,
        //         fee: mockProject().fee,
        //         initialPoolPriceX96: mockProject().initialPoolPriceX96,
        //         launchTime: mockProject().launchTime
        //     })
        // );
    }

    function _initProject(address initializer) internal {
        hoax(initializer);
        iloManager.initProject{ value: 1 ether }(
            IILOManager.InitProjectParams({
                projectId: PROJECT_ID,
                pairToken: USDC,
                fee: FEE,
                initialPoolPriceX96: INIT_SQRT_PRICE_X96
            })
        );
    }

    function _initPool(
        address initializer,
        IILOPoolBase.InitPoolParams memory params
    ) internal returns (address iloPoolAddress) {
        vm.prank(initializer);
        iloPoolAddress = iloManager.initILOPool(params);
    }

    function _initPoolSale(
        address initializer,
        IILOPoolSale.InitParams memory params
    ) internal returns (address iloPoolSaleAddress) {
        vm.prank(initializer);
        iloPoolSaleAddress = iloManager.initILOPoolSale(params);
    }

    function _writeTokenBalance(
        address token,
        address who,
        uint256 amt
    ) internal {
        stdstore
            .target(token)
            .sig(IERC20(token).balanceOf.selector)
            .with_key(who)
            .checked_write(amt);
    }

    function _getInitPoolParams()
        internal
        pure
        returns (IILOPoolBase.InitPoolParams memory)
    {
        return
            IILOPoolBase.InitPoolParams({
                baseParams: IILOPoolBase.InitPoolBaseParams({
                    projectId: PROJECT_ID,
                    tokenAmount: 100000000 * 10 ** 18,
                    tickLower: MIN_TICK_10000,
                    tickUpper: -MIN_TICK_10000
                }),
                vestingConfigs: _getVestingConfigs()
            });
    }

    function _getInitPoolSaleParams()
        internal
        pure
        returns (IILOPoolSale.InitParams memory)
    {
        return
            IILOPoolSale.InitParams({
                baseParams: IILOPoolBase.InitPoolBaseParams({
                    projectId: PROJECT_ID,
                    tokenAmount: 10000000 * 10 ** 18, // 10M
                    tickLower: -10000,
                    tickUpper: -MIN_TICK_10000
                }),
                saleParams: IILOPoolSale.SaleParams({
                    start: SALE_START,
                    end: SALE_END, // Tue Jun 04 2024 17:00:00 GMT+0000
                    minRaise: 100000 * 10 ** 18, // 0.1M
                    maxRaise: 10000000 * 10 ** 18 // 10M
                }),
                vestingSchedule: _getLinearVesting()
            });
    }

    // function _getPairTokenAmount()

    function _getLiquidity(
        address token,
        address pairToken,
        uint256 tokenAmount,
        uint160 sqrtPriceX96,
        int24 tickLower,
        int24 tickUpper
    ) internal pure returns (uint128) {
        (uint256 amount0, uint256 amount1) = (tokenAmount, type(uint96).max);
        if (token < pairToken) {
            (amount0, amount1) = (amount1, amount0);
            (tickLower, tickUpper) = (-tickUpper, -tickLower);
            sqrtPriceX96 = uint160(2 ** 192 / sqrtPriceX96);
        }
        uint160 sqrtPriceX96Lower = TickMath.getSqrtRatioAtTick(tickLower);
        uint160 sqrtPriceX96Upper = TickMath.getSqrtRatioAtTick(tickUpper);

        return
            LiquidityAmounts.getLiquidityForAmounts(
                sqrtPriceX96,
                sqrtPriceX96Lower,
                sqrtPriceX96Upper,
                amount0,
                amount1
            );
    }
}
