// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';
import '@uniswap/v3-core/contracts/libraries/FixedPoint128.sol';
import '@uniswap/v3-core/contracts/libraries/FullMath.sol';

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';

import './interfaces/IILOPool.sol';
import './libraries/PositionKey.sol';
import './base/ILOSale.sol';
import './base/ILOVest.sol';
import './base/LiquidityManagement.sol';
import './base/ILOPoolImmutableState.sol';
import './base/Initializable.sol';
import './base/Multicall.sol';
import './base/PeripheryValidation.sol';
import './base/PoolInitializer.sol';
import "./base/ILOWhitelist.sol";

/// @title NFT positions
/// @notice Wraps Uniswap V3 positions in the ERC721 non-fungible token interface
contract ILOPool is
    ERC721,
    IILOPool,
    ILOWhitelist,
    ILOSale,
    ILOVest,
    Initializable,
    Multicall,
    ILOPoolImmutableState,
    PoolInitializer,
    LiquidityManagement,
    PeripheryValidation
{
    // details about the uniswap position
    struct Position {
        // the liquidity of the position
        uint128 liquidity;
        // the fee growth of the aggregate position as of the last action on the individual position
        uint256 feeGrowthInside0LastX128;
        uint256 feeGrowthInside1LastX128;
        // how many uncollected tokens are owed to the position, as of the last computation
        uint128 tokensOwed0;
        uint128 tokensOwed1;
    }

    LinearVest[] investorVestConfigs;

    /// @dev The token ID position data
    mapping(uint256 => Position) private _positions;

    /// @dev The ID of the next token that will be minted. Skips 0
    uint256 private _nextId = 1;
    uint256 totalRaised;
    constructor(
        address _factory,
        address _WETH9
    ) ERC721('KRYSTAL ILOPool V1', 'KYRSTAL-ILO-V1') ILOPoolImmutableState(_factory, _WETH9) {}

    function initialize(InitPoolParams calldata params) external override whenNotInitialized() {
        
        // initialize imutable state
        MANAGER = IILOManager(msg.sender);
        IILOManager.Project memory _project = MANAGER.project(params.uniV3Pool);

        RAISE_TOKEN = _project.raiseToken;
        SALE_TOKEN = _project.saleToken;
        _cacheUniV3PoolAddress(params.uniV3Pool);
        _cachePoolKey(_project._cachedPoolKey);
        TICK_LOWER = params.tickLower;
        TICK_UPPER = params.tickUpper;
        SQRT_RATIO_LOWER_X96 = TickMath.getSqrtRatioAtTick(TICK_LOWER);
        SQRT_RATIO_UPPER_X96 = TickMath.getSqrtRatioAtTick(TICK_UPPER);
        PLATFORM_FEE = _project.platformFee;
        INVESTOR_SHARES = _project.investorShares;

        // initialize sale
        saleInfo = SaleInfo({
            hardCap: params.hardCap,
            softCap: params.softCap,
            maxCapPerUser: params.maxCapPerUser,
            start: params.start,
            end: params.end,
            // rounding up to make sure that the number of sale token is enough for sale
            maxSaleAmount: _saleAmountNeeded(params.hardCap)
        });

        // initialize vesting
        uint256 vestConfigLength = params.investorVestConfigs.length;
        for (uint256 index = 0; index < vestConfigLength; index++) {
            investorVestConfigs.push(params.investorVestConfigs[index]);
        }
    }

    /// @inheritdoc IILOPool
    function positions(uint256 tokenId)
        external
        view
        override
        returns (
            address token0,
            address token1,
            uint24 fee,
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        )
    {
        Position memory position = _positions[tokenId];
        return (
            _poolKey().token0,
            _poolKey().token1,
            _poolKey().fee,
            TICK_LOWER,
            TICK_UPPER,
            position.liquidity,
            position.feeGrowthInside0LastX128,
            position.feeGrowthInside1LastX128,
            position.tokensOwed0,
            position.tokensOwed1
        );
    }

    /// @inheritdoc ILOSale
    function buy(BuyParams calldata params)
        external override 
        duringSale()
        onlyWhitelisted(params.recipient)
        returns (
            uint256 tokenId,
            uint128 liquidityDelta,
            uint256 amountAdded0,
            uint256 amountAdded1
        )
    {
        totalRaised += params.raiseAmount;
        require(totalRaised <= saleInfo.hardCap);
        if (balanceOf(params.recipient) == 0) {
            _mint(params.recipient, (tokenId = _nextId++));
        } else {
            tokenId = tokenOfOwnerByIndex(params.recipient, 1);
        }
        Position storage _position = _positions[tokenId];
        if (RAISE_TOKEN == _poolKey().token0) {
            require(_position.tokensOwed0 + params.raiseAmount <= saleInfo.maxCapPerUser);
            liquidityDelta = LiquidityAmounts.getLiquidityForAmount0(SQRT_RATIO_X96, SQRT_RATIO_UPPER_X96, params.raiseAmount);
        } else {
            require(_position.tokensOwed1 + params.raiseAmount <= saleInfo.maxCapPerUser);
            liquidityDelta = LiquidityAmounts.getLiquidityForAmount1(SQRT_RATIO_LOWER_X96, SQRT_RATIO_X96, params.raiseAmount);
        }

        require(totalSold() <= saleInfo.maxSaleAmount);

        liquidityDelta = uint128(FullMath.mulDiv(liquidityDelta, INVESTOR_SHARES, BPS));
        _position.liquidity += liquidityDelta;
        (amountAdded0, amountAdded1) = LiquidityAmounts.getAmountsForLiquidity(
            SQRT_RATIO_X96,
            SQRT_RATIO_LOWER_X96,
            SQRT_RATIO_UPPER_X96,
            liquidityDelta
        );
        _position.tokensOwed0 += uint128(amountAdded0);
        _position.tokensOwed1 += uint128(amountAdded1);

        _updateVestingLiquidity(tokenId, liquidityDelta);
        _assignVestingSchedule(tokenId, investorVestConfigs);
    }



    modifier isAuthorizedForToken(uint256 tokenId) {
        require(_isApprovedOrOwner(msg.sender, tokenId), 'Not approved');
        _;
    }

    /// @inheritdoc IILOPool
    function decreaseLiquidity(DecreaseLiquidityParams calldata params)
        external
        payable
        override
        isAuthorizedForToken(params.tokenId)
        afterSale()
        checkDeadline(params.deadline)
        returns (uint256 amount0, uint256 amount1)
    {
        require(params.liquidity > 0);
        require(params.liquidity + _positionVests[params.tokenId].claimedLiquidity <= _unlockedLiquidity(params.tokenId));
        Position storage position = _positions[params.tokenId];

        uint128 positionLiquidity = position.liquidity;
        require(positionLiquidity >= params.liquidity);

        IUniswapV3Pool pool = IUniswapV3Pool(_uniV3PoolAddress());
        (amount0, amount1) = pool.burn(TICK_LOWER, TICK_UPPER, params.liquidity);

        require(amount0 >= params.amount0Min && amount1 >= params.amount1Min, 'Price slippage check');

        bytes32 positionKey = PositionKey.compute(address(this), TICK_LOWER, TICK_UPPER);
        // this is now updated to the current transaction
        (, uint256 feeGrowthInside0LastX128, uint256 feeGrowthInside1LastX128, , ) = pool.positions(positionKey);

        position.tokensOwed0 +=
            uint128(amount0) +
            uint128(
                FullMath.mulDiv(
                    feeGrowthInside0LastX128 - position.feeGrowthInside0LastX128,
                    positionLiquidity,
                    FixedPoint128.Q128
                )
            );
        position.tokensOwed1 +=
            uint128(amount1) +
            uint128(
                FullMath.mulDiv(
                    feeGrowthInside1LastX128 - position.feeGrowthInside1LastX128,
                    positionLiquidity,
                    FixedPoint128.Q128
                )
            );

        position.feeGrowthInside0LastX128 = feeGrowthInside0LastX128;
        position.feeGrowthInside1LastX128 = feeGrowthInside1LastX128;
        // subtraction is safe because we checked positionLiquidity is gte params.liquidity
        position.liquidity = positionLiquidity - params.liquidity;

        emit DecreaseLiquidity(params.tokenId, params.liquidity, amount0, amount1);
    }

    /// @inheritdoc IILOPool
    function collect(CollectParams calldata params)
        external
        payable
        override
        isAuthorizedForToken(params.tokenId)
        returns (uint256 amount0, uint256 amount1)
    {
        require(params.amount0Max > 0 || params.amount1Max > 0);
        // allow collecting to the nft position manager address with address 0
        address recipient = params.recipient == address(0) ? address(this) : params.recipient;

        Position storage position = _positions[params.tokenId];

        IUniswapV3Pool pool = IUniswapV3Pool(PoolAddress.computeAddress(factory, _poolKey()));

        (uint128 tokensOwed0, uint128 tokensOwed1) = (position.tokensOwed0, position.tokensOwed1);

        // trigger an update of the position fees owed and fee growth snapshots if it has any liquidity
        if (position.liquidity > 0) {
            pool.burn(TICK_LOWER, TICK_UPPER, 0);
            (, uint256 feeGrowthInside0LastX128, uint256 feeGrowthInside1LastX128, , ) =
                pool.positions(PositionKey.compute(address(this), TICK_LOWER, TICK_UPPER));

            tokensOwed0 += uint128(
                FullMath.mulDiv(
                    feeGrowthInside0LastX128 - position.feeGrowthInside0LastX128,
                    position.liquidity,
                    FixedPoint128.Q128
                )
            );
            tokensOwed1 += uint128(
                FullMath.mulDiv(
                    feeGrowthInside1LastX128 - position.feeGrowthInside1LastX128,
                    position.liquidity,
                    FixedPoint128.Q128
                )
            );

            position.feeGrowthInside0LastX128 = feeGrowthInside0LastX128;
            position.feeGrowthInside1LastX128 = feeGrowthInside1LastX128;
        }

        // compute the arguments to give to the pool#collect method
        (uint128 amount0Collect, uint128 amount1Collect) =
            (
                params.amount0Max > tokensOwed0 ? tokensOwed0 : params.amount0Max,
                params.amount1Max > tokensOwed1 ? tokensOwed1 : params.amount1Max
            );

        // the actual amounts collected are returned
        (amount0, amount1) = pool.collect(
            recipient,
            TICK_LOWER,
            TICK_UPPER,
            amount0Collect,
            amount1Collect
        );

        // sometimes there will be a few less wei than expected due to rounding down in core, but we just subtract the full amount expected
        // instead of the actual amount so we can burn the token
        (position.tokensOwed0, position.tokensOwed1) = (tokensOwed0 - amount0Collect, tokensOwed1 - amount1Collect);

        emit Collect(params.tokenId, recipient, amount0Collect, amount1Collect);
    }

    /// @inheritdoc IILOPool
    function burn(uint256 tokenId) external payable override isAuthorizedForToken(tokenId) {
        Position storage position = _positions[tokenId];
        require(position.liquidity == 0 && position.tokensOwed0 == 0 && position.tokensOwed1 == 0, 'Not cleared');
        delete _positions[tokenId];
        _burn(tokenId);
    }

    /// @inheritdoc IILOPool
    function launch() external override afterSale() {
        require(msg.sender == address(MANAGER));
        require(totalRaised >= saleInfo.softCap);
        uint256 liquidity;
        {
            uint256 amount0Desired;
            uint256 amount1Desired;
            uint256 amount0Min;
            uint256 amount1Min;
            if (_poolKey().token0 == RAISE_TOKEN) {
                amount0Desired = totalRaised;
                amount0Min = totalRaised;
                amount1Desired = _saleAmountNeeded(totalRaised);
            } else {
                amount0Desired = _saleAmountNeeded(totalRaised);
                amount1Desired = totalRaised;
                amount1Min = totalRaised;
            }
            (liquidity,,,) = addLiquidity(AddLiquidityParams({
                token0: _poolKey().token0,
                token1: _poolKey().token1,
                fee: _poolKey().fee,
                recipient: address(this),
                tickLower: TICK_LOWER,
                tickUpper: TICK_UPPER,
                amount0Desired: amount0Desired,
                amount1Desired: amount1Desired,
                amount0Min: amount0Min,
                amount1Min: amount1Min
            }));
        }

        IILOManager.Project memory _project = MANAGER.project(_uniV3PoolAddress());
        for (uint256 index = 0; index < _project.projectVestConfigs.length; index++) {
            uint256 tokenId;
            IILOManager.ProjectVestConfig memory projectConfig = _project.projectVestConfigs[index];
            _mint(projectConfig.recipient, (tokenId = _nextId++));
            uint128 liquidityShares = uint128(FullMath.mulDiv(liquidity, projectConfig.shares, BPS));

            Position storage _position = _positions[tokenId];
            _position.liquidity = liquidityShares;
            (uint256 amount0, uint256 amount1) = LiquidityAmounts.getAmountsForLiquidity(
                SQRT_RATIO_X96,
                SQRT_RATIO_LOWER_X96,
                SQRT_RATIO_UPPER_X96,
                liquidityShares
            );

            _position.tokensOwed0 = uint128(amount0);
            _position.tokensOwed1 = uint128(amount1);

            
            _updateVestingLiquidity(tokenId, liquidityShares);

            // assign vesting schedule
            LinearVest[] storage schedule = _positionVests[tokenId].schedule;
            for (uint256 i = 0; i < projectConfig.vestSchedule.length; i++) {
                schedule.push(projectConfig.vestSchedule[i]);
            }
        }
    }

    function totalSold() public view returns (uint256) {
        return _saleAmountNeeded(totalRaised);
    }

    function _saleAmountNeeded(uint256 raiseAmount) internal view returns (uint256) {
        if (raiseAmount == 0) return 0;
        return _poolKey().token0 == SALE_TOKEN
                ? LiquidityAmounts.getInrangeAmount0ForAmount1(
                    SQRT_RATIO_X96, 
                    SQRT_RATIO_LOWER_X96, 
                    SQRT_RATIO_UPPER_X96, 
                    raiseAmount,
                    true
                )
                : LiquidityAmounts.getInrangeAmount1ForAmount0(
                    SQRT_RATIO_X96, 
                    SQRT_RATIO_LOWER_X96, 
                    SQRT_RATIO_UPPER_X96, 
                    raiseAmount,
                    true
                );
    }

    function _unlockedLiquidity(uint256 tokenId) internal view override returns (uint128 unlockedLiquidity) {
        PositionVest storage _positionVest = _positionVests[tokenId];
        unlockedLiquidity = uint128(FullMath.mulDiv(
                _positionVest.totalLiquidity,
                _unlockedSharesBPS(_positionVest.schedule), 
                BPS
            ));
    }

    function _assignVestingSchedule(uint256 nftId, LinearVest[] storage vestingSchedule) internal {
        _positionVests[nftId].schedule = vestingSchedule;
    }

    function _updateVestingLiquidity(uint256 nftId, uint128 liquidity) internal {
        _positionVests[nftId].totalLiquidity = liquidity;
    }
}
