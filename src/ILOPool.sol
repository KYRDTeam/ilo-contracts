// SPDX-License-Identifier: BSL-1.1
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
    LiquidityManagement,
    PeripheryValidation
{
    event Claim(address indexed user, uint128 liquidity, uint256 amount0, uint256 amount1);

    // details about the uniswap position
    struct Position {
        // the liquidity of the position
        uint128 liquidity;
        // the fee growth of the aggregate position as of the last action on the individual position
        uint256 feeGrowthInside0LastX128;
        uint256 feeGrowthInside1LastX128;
        
        // the raise amount of position
        uint256 raiseAmount;
    }

    LinearVest[] investorVestConfigs;

    /// @dev The token ID position data
    mapping(uint256 => Position) private _positions;

    /// @dev The ID of the next token that will be minted. Skips 0
    uint256 private _nextId = 1;
    uint256 totalRaised;
    constructor() ERC721('KYRSTAL ILOPool V1', 'KYRSTAL-ILO-V1') {
        _disableInitialize();
    }

    function name() public pure override(ERC721, IERC721Metadata) returns (string memory) {
        return 'KYRSTAL ILOPool V1';
    }

    function symbol() public pure override(ERC721, IERC721Metadata) returns (string memory) {
        return 'KYRSTAL-ILO-V1';
    }

    function initialize(InitPoolParams calldata params) external override whenNotInitialized() {
        // initialize imutable state
        MANAGER = IILOManager(msg.sender);
        IILOManager.Project memory _project = MANAGER.project(params.uniV3Pool);

        WETH9 = MANAGER.WETH9();
        RAISE_TOKEN = _project.raiseToken;
        SALE_TOKEN = _project.saleToken;
        _cacheUniV3PoolAddress(params.uniV3Pool);
        _cachePoolKey(_project._cachedPoolKey);
        TICK_LOWER = params.tickLower;
        TICK_UPPER = params.tickUpper;
        SQRT_RATIO_LOWER_X96 = TickMath.getSqrtRatioAtTick(TICK_LOWER);
        SQRT_RATIO_UPPER_X96 = TickMath.getSqrtRatioAtTick(TICK_UPPER);
        PLATFORM_FEE = _project.platformFee;
        PERFORMANCE_FEE = _project.performanceFee;
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

        emit ILOPoolInitialized(
          params.uniV3Pool,
          TICK_LOWER,
          TICK_UPPER,
          PLATFORM_FEE,
          PERFORMANCE_FEE,
          INVESTOR_SHARES,
          saleInfo
        );
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
            uint256 feeGrowthInside1LastX128
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
            position.feeGrowthInside1LastX128
        );
    }

    /// @inheritdoc ILOSale
    function buy(uint256 raiseAmount, address recipient)
        external override 
        duringSale()
        onlyWhitelisted(recipient)
        returns (
            uint256 tokenId,
            uint128 liquidityDelta,
            uint256 amountAdded0,
            uint256 amountAdded1
        )
    {
        totalRaised += raiseAmount;
        require(totalRaised <= saleInfo.hardCap);
        require(totalSold() <= saleInfo.maxSaleAmount);

        if (balanceOf(recipient) == 0) {
            _mint(recipient, (tokenId = _nextId++));
        } else {
            tokenId = tokenOfOwnerByIndex(recipient, 1);
        }

        Position storage _position = _positions[tokenId];
        require(_position.raiseAmount + raiseAmount <= saleInfo.maxCapPerUser);

        if (RAISE_TOKEN == _poolKey().token0) {
            liquidityDelta = LiquidityAmounts.getLiquidityForAmount0(SQRT_RATIO_X96, SQRT_RATIO_UPPER_X96, raiseAmount);
        } else {
            liquidityDelta = LiquidityAmounts.getLiquidityForAmount1(SQRT_RATIO_LOWER_X96, SQRT_RATIO_X96, raiseAmount);
        }

        liquidityDelta = uint128(FullMath.mulDiv(liquidityDelta, INVESTOR_SHARES, BPS));
        _position.liquidity += liquidityDelta;
        (amountAdded0, amountAdded1) = LiquidityAmounts.getAmountsForLiquidity(
            SQRT_RATIO_X96,
            SQRT_RATIO_LOWER_X96,
            SQRT_RATIO_UPPER_X96,
            liquidityDelta
        );

        _updateVestingLiquidity(tokenId, liquidityDelta);
        _assignVestingSchedule(tokenId, investorVestConfigs);
    }

    modifier isAuthorizedForToken(uint256 tokenId) {
        require(_isApprovedOrOwner(msg.sender, tokenId), 'Not approved');
        _;
    }

    function claim(uint256 tokenId)
        external
        payable
        override
        isAuthorizedForToken(tokenId)
        afterSale()
        returns (uint256 amount0, uint256 amount1)
    {
        uint128 unlockedLiquidity = _unlockedLiquidity(tokenId);
        IUniswapV3Pool pool = IUniswapV3Pool(_uniV3PoolAddress());
        {
            Position storage position = _positions[tokenId];

            uint128 positionLiquidity = position.liquidity;
            require(positionLiquidity >= unlockedLiquidity);

            (amount0, amount1) = pool.burn(TICK_LOWER, TICK_UPPER, unlockedLiquidity);

            (amount0, amount1) = _deductFees(amount0, amount1, PLATFORM_FEE);
            bytes32 positionKey = PositionKey.compute(address(this), TICK_LOWER, TICK_UPPER);

            (, uint256 feeGrowthInside0LastX128, uint256 feeGrowthInside1LastX128, , ) = pool.positions(positionKey);
            uint256 fees0 = FullMath.mulDiv(
                                feeGrowthInside0LastX128 - position.feeGrowthInside0LastX128,
                                positionLiquidity,
                                FixedPoint128.Q128
                            );
            
            uint256 fees1 = FullMath.mulDiv(
                                feeGrowthInside1LastX128 - position.feeGrowthInside1LastX128,
                                positionLiquidity,
                                FixedPoint128.Q128
                            );
            (fees0, fees1) = _deductFees(fees0, fees1, PERFORMANCE_FEE);

            amount0 += fees0;
            amount1 += fees1;

            position.feeGrowthInside0LastX128 = feeGrowthInside0LastX128;
            position.feeGrowthInside1LastX128 = feeGrowthInside1LastX128;

            // subtraction is safe because we checked positionLiquidity is gte unlockedLiquidity
            position.liquidity = positionLiquidity - unlockedLiquidity;
            emit DecreaseLiquidity(tokenId, unlockedLiquidity, amount0, amount1);

        }
        (uint128 amountCollected0, uint128 amountCollected1) = pool.collect(
            address(this),
            TICK_LOWER,
            TICK_UPPER,
            type(uint128).max,
            type(uint128).max
        );
        emit Collect(tokenId, address(this), amountCollected0, amountCollected1);

        TransferHelper.safeTransfer(_poolKey().token0, msg.sender, amount0);
        TransferHelper.safeTransfer(_poolKey().token1, msg.sender, amount1);

        emit Claim(msg.sender, unlockedLiquidity, amount0, amount1);

        // transfer fee
        address feeTaker = MANAGER.feeTaker();
        TransferHelper.safeTransfer(_poolKey().token0, feeTaker, amountCollected0-amount0);
        TransferHelper.safeTransfer(_poolKey().token1, feeTaker, amountCollected1-amount1);

    }

    /// @inheritdoc IILOPool
    function burn(uint256 tokenId) external payable override isAuthorizedForToken(tokenId) {
        Position storage position = _positions[tokenId];
        require(position.liquidity == 0, 'Not cleared');
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
            (liquidity,,) = addLiquidity(AddLiquidityParams({
                pool: IUniswapV3Pool(_uniV3PoolAddress()),
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

    function _deductFees(uint256 amount0, uint256 amount1, uint16 feeBPS) internal pure 
        returns (
            uint256 amount0Left, 
            uint256 amount1Left
        ) {
        amount0Left = amount0 - FullMath.mulDiv(amount0, feeBPS, BPS);
        amount1Left = amount1 - FullMath.mulDiv(amount1, feeBPS, BPS);
    }
}
