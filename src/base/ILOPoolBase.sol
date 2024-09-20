// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.7.6;
pragma abicoder v2;

import { TransferHelper } from '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import { Multicall } from '@uniswap/v3-periphery/contracts/base/Multicall.sol';
import { PositionKey } from '@uniswap/v3-periphery/contracts/libraries/PositionKey.sol';
import { LiquidityAmounts } from '@uniswap/v3-periphery/contracts/libraries/LiquidityAmounts.sol';
import { PoolAddress } from '@uniswap/v3-periphery/contracts/libraries/PoolAddress.sol';
import { IUniswapV3Pool } from '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';
import { FixedPoint128 } from '@uniswap/v3-core/contracts/libraries/FixedPoint128.sol';
import { FullMath } from '@uniswap/v3-core/contracts/libraries/FullMath.sol';
import { ERC721, IERC721Metadata } from '@openzeppelin/contracts/token/ERC721/ERC721.sol';

import { IILOPoolBase } from '../interfaces/IILOPoolBase.sol';
import { ILOVest } from './ILOVest.sol';
import { LiquidityManagement } from './LiquidityManagement.sol';
import { ILOPoolImmutableState } from './ILOPoolImmutableState.sol';
import { Initializable } from './Initializable.sol';
import { IILOManager } from '../interfaces/IILOManager.sol';

/// @title NFT positions
/// @notice Wraps Uniswap V3 positions in the ERC721 non-fungible token interface
abstract contract ILOPoolBase is
    IILOPoolBase,
    ERC721,
    ILOVest,
    ILOPoolImmutableState,
    Initializable,
    Multicall,
    LiquidityManagement
{
    bool public override CANCELLED;
    /// @dev The token ID position data
    mapping(uint256 => Position) internal _positions;

    /// @dev The ID of the next token that will be minted. Skips 0
    uint256 internal _nextId;
    uint256 internal _tokenAmount;
    uint128 internal _totalInitialLiquidity;

    modifier onlyInitializedProject() {
        IILOManager.Project memory _project = IILOManager(MANAGER).project(
            PROJECT_ID
        );
        require(_project.status == IILOManager.ProjectStatus.INITIALIZED, 'PL');
        _;
    }

    modifier isAuthorizedForToken(uint256 tokenId) {
        require(_isApprovedOrOwner(msg.sender, tokenId), 'UA');
        _;
    }

    modifier onlyManager() {
        require(msg.sender == address(MANAGER), 'UA');
        _;
    }

    modifier afterLaunch() {
        IILOManager.Project memory _project = IILOManager(MANAGER).project(
            PROJECT_ID
        );
        require(_project.status == IILOManager.ProjectStatus.LAUNCHED, 'PL');
        _;
    }

    modifier whenNotCancelled() {
        require(!CANCELLED, 'CANCELLED');
        _;
    }

    constructor() ERC721('', '') {
        _disableInitialize();
    }

    function burn(uint256 tokenId) external isAuthorizedForToken(tokenId) {
        _burn(tokenId);
    }

    function positions(
        uint256 tokenId
    ) external view override returns (Position memory) {
        return _positions[tokenId];
    }

    function totalInititalLiquidity()
        external
        view
        override
        returns (uint128 liquidity)
    {
        return _totalInitialLiquidity;
    }

    function name()
        public
        view
        override(ERC721, IERC721Metadata)
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(
                    'KRYSTAL ILO ',
                    IILOManager(MANAGER).project(PROJECT_ID).tokenSymbol
                )
            );
    }

    function symbol()
        public
        view
        override(ERC721, IERC721Metadata)
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(
                    'KRYSTAL_ILO_',
                    IILOManager(MANAGER).project(PROJECT_ID).tokenSymbol
                )
            );
    }

    function _claim(
        uint256 tokenId
    )
        internal
        isAuthorizedForToken(tokenId)
        afterLaunch
        returns (uint256 amount0, uint256 amount1)
    {
        // calculate amount of unlocked liquidity for the position
        uint128 liquidity2Claim = _claimableLiquidity(tokenId);
        IUniswapV3Pool pool = IUniswapV3Pool(_cachedUniV3PoolAddress);
        Position storage position = _positions[tokenId];
        uint256 fees0;
        uint256 fees1;
        uint128 amountCollected0;
        uint128 amountCollected1;
        {
            IILOManager.Project memory _project = IILOManager(MANAGER).project(
                PROJECT_ID
            );
            {
                uint128 positionLiquidity = position.liquidity;
                require(positionLiquidity >= liquidity2Claim);

                // get amount of token0 and token1 that pool will return for us
                (amount0, amount1) = pool.burn(
                    TICK_LOWER,
                    TICK_UPPER,
                    liquidity2Claim
                );
                emit DecreaseLiquidity(
                    tokenId,
                    liquidity2Claim,
                    amount0,
                    amount1
                );

                // calculate amount of fees that position generated
                bytes32 positionKey = PositionKey.compute(
                    address(this),
                    TICK_LOWER,
                    TICK_UPPER
                );
                (
                    ,
                    uint256 feeGrowthInside0LastX128,
                    uint256 feeGrowthInside1LastX128,
                    ,

                ) = pool.positions(positionKey);
                fees0 = FullMath.mulDiv(
                    feeGrowthInside0LastX128 -
                        position.feeGrowthInside0LastX128,
                    positionLiquidity,
                    FixedPoint128.Q128
                );

                fees1 = FullMath.mulDiv(
                    feeGrowthInside1LastX128 -
                        position.feeGrowthInside1LastX128,
                    positionLiquidity,
                    FixedPoint128.Q128
                );

                position.feeGrowthInside0LastX128 = feeGrowthInside0LastX128;
                position.feeGrowthInside1LastX128 = feeGrowthInside1LastX128;
            }

            // to avoid stack too deep, we temparory store amount request into amountCollected
            amountCollected0 = uint128(amount0 + fees0);
            amountCollected1 = uint128(amount1 + fees1);

            // real amount collected from uintswap pool
            // some times amountCollected0 < amount0 + fees0, this is due to rounding down in uniswap v3 pool
            // this diff is really small, so we can ignore it
            (amountCollected0, amountCollected1) = pool.collect(
                address(this),
                TICK_LOWER,
                TICK_UPPER,
                amountCollected0,
                amountCollected1
            );

            if (_project.platformFee > 0) {
                // get amount of token0 and token1 after deduct platform fee
                (amount0, amount1) = _deductFees(
                    amount0,
                    amount1,
                    _project.platformFee
                );
            }

            if (_project.performanceFee > 0) {
                // amount of fees after deduct performance fee
                (fees0, fees1) = _deductFees(
                    fees0,
                    fees1,
                    _project.performanceFee
                );
            }

            // fees is combined with liquidity token amount to return to the user
            amount0 += fees0;
            amount1 += fees1;

            // if platformFee and performanceFee is 0, amountCollected might be smaller than amount due to rounding down in uniswap v3 pool
            amount0 = amount0 > amountCollected0 ? amountCollected0 : amount0;
            amount1 = amount1 > amountCollected1 ? amountCollected1 : amount1;

            // subtraction is safe because we checked positionLiquidity is gte liquidity2Claim
            position.liquidity -= liquidity2Claim;
            emit Collect(
                tokenId,
                address(this),
                amountCollected0,
                amountCollected1
            );
        }

        // transfer token for user
        TransferHelper.safeTransfer(
            _cachedPoolKey.token0,
            ownerOf(tokenId),
            amount0
        );
        TransferHelper.safeTransfer(
            _cachedPoolKey.token1,
            ownerOf(tokenId),
            amount1
        );

        emit Claim(
            ownerOf(tokenId),
            tokenId,
            liquidity2Claim,
            amount0,
            amount1,
            position.feeGrowthInside0LastX128,
            position.feeGrowthInside1LastX128,
            fees0,
            fees1
        );

        address feeTaker = IILOManager(MANAGER).FEE_TAKER();
        // transfer fee to fee taker
        TransferHelper.safeTransfer(
            _cachedPoolKey.token0,
            feeTaker,
            amountCollected0 - amount0
        );
        TransferHelper.safeTransfer(
            _cachedPoolKey.token1,
            feeTaker,
            amountCollected1 - amount1
        );
    }

    /// @inheritdoc ERC721
    function _burn(uint256 tokenId) internal override {
        delete _positions[tokenId];
        delete _positionVests[tokenId];
        super._burn(tokenId);
    }

    function _initialize(
        InitPoolBaseParams calldata params
    ) internal whenNotInitialized {
        _nextId = 1;
        _tokenAmount = params.tokenAmount;
        // initialize imutable state
        _initializeImmutableState(
            params.projectId,
            msg.sender,
            params.tickLower,
            params.tickUpper
        );
    }

    function _launchLiquidity(
        address uniV3PoolAddress,
        PoolAddress.PoolKey calldata poolKey,
        uint160 sqrtPriceX96,
        uint256 tokenAmount
    ) internal returns (uint128 liquidity) {
        _cachedUniV3PoolAddress = uniV3PoolAddress;
        _cachedPoolKey = poolKey;
        bool isFlip01 = poolKey.token0 == PAIR_TOKEN;
        uint160 sqrtLower = 0;
        uint160 sqrtUpper = 0;
        if (isFlip01) {
            _flipTicks();
            sqrtLower = _sqrtRatioLowerX96();
            sqrtUpper = _sqrtRatioUpperX96();
            if (sqrtPriceX96 > sqrtUpper) {
                sqrtPriceX96 = sqrtUpper;
            }
            liquidity = LiquidityAmounts.getLiquidityForAmount1(
                sqrtLower,
                sqrtPriceX96,
                tokenAmount
            );
        } else {
            sqrtLower = _sqrtRatioLowerX96();
            sqrtUpper = _sqrtRatioUpperX96();
            if (sqrtPriceX96 < sqrtLower) {
                sqrtPriceX96 = sqrtLower;
            }
            liquidity = LiquidityAmounts.getLiquidityForAmount0(
                sqrtPriceX96,
                sqrtUpper,
                tokenAmount
            );
        }

        // actually deploy liquidity to uniswap pool
        (uint256 amount0, uint256 amount1) = _addLiquidity(
            AddLiquidityParams({
                pool: IUniswapV3Pool(uniV3PoolAddress),
                liquidity: liquidity
            })
        );

        _totalInitialLiquidity = liquidity;

        emit PoolLaunch(uniV3PoolAddress, liquidity, amount0, amount1);
    }

    function _cancel() internal whenNotCancelled {
        CANCELLED = true;
        emit PoolCancelled();
    }

    /// @notice calculate amount of liquidity unlocked for claim
    /// @param totalLiquidity total liquidity to vest
    /// @param vestingSchedule the vesting schedule
    function _unlockedLiquidity(
        uint128 totalLiquidity,
        LinearVest[] storage vestingSchedule
    ) internal view returns (uint128 liquidityUnlocked) {
        for (uint256 index = 0; index < vestingSchedule.length; index++) {
            LinearVest storage vest = vestingSchedule[index];

            // if vest is not started, skip this vest and all following vest
            if (block.timestamp < vest.start) {
                break;
            }

            // if vest already end, all the shares are unlocked
            // otherwise we calculate shares of unlocked times and get the unlocked share number
            // all vest after current unlocking vest is ignored
            if (vest.end < block.timestamp) {
                liquidityUnlocked += uint128(
                    FullMath.mulDiv(vest.shares, totalLiquidity, BPS)
                );
            } else {
                liquidityUnlocked += uint128(
                    FullMath.mulDiv(
                        vest.shares * totalLiquidity,
                        block.timestamp - vest.start,
                        (vest.end - vest.start) * BPS
                    )
                );
            }
        }
    }

    function _claimableLiquidity(
        uint256 tokenId
    ) internal view returns (uint128) {
        uint128 liquidityClaimed = _positionVests[tokenId].totalLiquidity -
            _positions[tokenId].liquidity;
        uint128 liquidityUnlocked = _unlockedLiquidity(
            _positionVests[tokenId].totalLiquidity,
            _positionVests[tokenId].schedule
        );
        return
            liquidityClaimed < liquidityUnlocked
                ? liquidityUnlocked - liquidityClaimed
                : 0;
    }

    /// @notice calculate the amount left after deduct fee
    /// @param amount0 the amount of token0 before deduct fee
    /// @param amount1 the amount of token1 before deduct fee
    /// @return amount0Left the amount of token0 after deduct fee
    /// @return amount1Left the amount of token1 after deduct fee
    function _deductFees(
        uint256 amount0,
        uint256 amount1,
        uint16 feeBPS
    ) internal pure returns (uint256 amount0Left, uint256 amount1Left) {
        amount0Left = amount0 - FullMath.mulDiv(amount0, feeBPS, BPS);
        amount1Left = amount1 - FullMath.mulDiv(amount1, feeBPS, BPS);
    }
}
