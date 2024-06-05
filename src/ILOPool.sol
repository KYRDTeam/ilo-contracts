// SPDX-License-Identifier: BUSL-1.1
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

    /// @dev when lauch successfully we can not refund anymore
    bool private _launchSucceeded;

    /// @dev when refund triggered, we can not launch anymore
    bool private _refundTriggered;

    LinearVest[] investorVestConfigs;

    /// @dev The token ID position data
    mapping(uint256 => Position) private _positions;

    /// @dev The ID of the next token that will be minted. Skips 0
    uint256 private _nextId = 1;
    uint256 totalRaised;
    constructor() ERC721('KRYSTAL ILOPool V1', 'KRYSTAL-ILO-V1') {
        _disableInitialize();
    }

    function name() public pure override(ERC721, IERC721Metadata) returns (string memory) {
        return 'KRYSTAL ILOPool V1';
    }

    function symbol() public pure override(ERC721, IERC721Metadata) returns (string memory) {
        return 'KRYSTAL-ILO-V1';
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
            saleInfo,
            params.investorVestConfigs
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
        // check if raise amount over capacity
        require(saleInfo.hardCap - totalRaised >= raiseAmount);
        totalRaised += raiseAmount;

        require(totalSold() <= saleInfo.maxSaleAmount);

        // if investor already have a position, just increase raise amount and liquidity
        // otherwise, mint new nft for investor and assign vesting schedules
        if (balanceOf(recipient) == 0) {
            _mint(recipient, (tokenId = _nextId++));
            _assignVestingSchedule(tokenId, investorVestConfigs);
        } else {
            tokenId = tokenOfOwnerByIndex(recipient, 1);
        }

        Position storage _position = _positions[tokenId];
        require(raiseAmount <= saleInfo.maxCapPerUser - _position.raiseAmount);

        // get amount of liquidity associated with raise amount
        if (RAISE_TOKEN == _poolKey().token0) {
            liquidityDelta = LiquidityAmounts.getLiquidityForAmount0(SQRT_RATIO_X96, SQRT_RATIO_UPPER_X96, raiseAmount);
        } else {
            liquidityDelta = LiquidityAmounts.getLiquidityForAmount1(SQRT_RATIO_LOWER_X96, SQRT_RATIO_X96, raiseAmount);
        }

        // calculate amount of share liquidity investor recieve by INVESTOR_SHARES config
        liquidityDelta = uint128(FullMath.mulDiv(liquidityDelta, INVESTOR_SHARES, BPS));
        
        // increase investor's liquidity
        _position.liquidity += liquidityDelta;
        (amountAdded0, amountAdded1) = LiquidityAmounts.getAmountsForLiquidity(
            SQRT_RATIO_X96,
            SQRT_RATIO_LOWER_X96,
            SQRT_RATIO_UPPER_X96,
            liquidityDelta
        );

        // update total liquidity locked for vest and assiging vesing schedules
        _updateVestingLiquidity(tokenId, _position.liquidity);

        // transfer fund into contract
        TransferHelper.safeTransferFrom(RAISE_TOKEN, msg.sender, address(this), raiseAmount);

        emit Buy(recipient, tokenId, raiseAmount, liquidityDelta);
    }

    modifier isAuthorizedForToken(uint256 tokenId) {
        require(_isApprovedOrOwner(msg.sender, tokenId), 'Not approved');
        _;
    }

    /// @inheritdoc IILOPool
    function claim(uint256 tokenId)
        external
        payable
        override
        isAuthorizedForToken(tokenId)
        returns (uint256 amount0, uint256 amount1)
    {
        // only can claim if the launch is successfully
        require(_launchSucceeded);

        // calculate amount of unlocked liquidity for the position
        uint128 liquidity2Claim = _claimableLiquidity(tokenId);
        IUniswapV3Pool pool = IUniswapV3Pool(_uniV3PoolAddress());
        {
            Position storage position = _positions[tokenId];

            uint128 positionLiquidity = position.liquidity;
            require(positionLiquidity >= liquidity2Claim);

            // get amount of token0 and token1 that pool will return for us
            (amount0, amount1) = pool.burn(TICK_LOWER, TICK_UPPER, liquidity2Claim);

            // get amount of token0 and token1 after deduct platform fee
            (amount0, amount1) = _deductFees(amount0, amount1, PLATFORM_FEE);

            bytes32 positionKey = PositionKey.compute(address(this), TICK_LOWER, TICK_UPPER);

            // calculate amount of fees that position generated
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

            // amount of fees after deduct performance fee
            (fees0, fees1) = _deductFees(fees0, fees1, PERFORMANCE_FEE);

            // fees is combined with liquidity token amount to return to the user
            amount0 += fees0;
            amount1 += fees1;

            position.feeGrowthInside0LastX128 = feeGrowthInside0LastX128;
            position.feeGrowthInside1LastX128 = feeGrowthInside1LastX128;

            // subtraction is safe because we checked positionLiquidity is gte liquidity2Claim
            position.liquidity = positionLiquidity - liquidity2Claim;
            emit DecreaseLiquidity(tokenId, liquidity2Claim, amount0, amount1);

        }
        // real amount collected from uintswap pool
        (uint128 amountCollected0, uint128 amountCollected1) = pool.collect(
            address(this),
            TICK_LOWER,
            TICK_UPPER,
            type(uint128).max,
            type(uint128).max
        );
        emit Collect(tokenId, address(this), amountCollected0, amountCollected1);

        // transfer token for user
        TransferHelper.safeTransfer(_poolKey().token0, ownerOf(tokenId), amount0);
        TransferHelper.safeTransfer(_poolKey().token1, ownerOf(tokenId), amount1);

        emit Claim(ownerOf(tokenId), liquidity2Claim, amount0, amount1);

        address feeTaker = MANAGER.feeTaker();
        // transfer fee to fee taker
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

    modifier OnlyManager() {
        require(msg.sender == address(MANAGER));
        _;
    }

    /// @inheritdoc IILOPool
    function launch() external override afterSale() OnlyManager() {
        require(!_launchSucceeded);
        // when refund triggered, we can not launch pool anymore
        require(!_refundTriggered);
        // make sure that soft cap requirement match
        require(totalRaised >= saleInfo.softCap);
        uint128 liquidity;
        {
            uint256 amount0Desired;
            uint256 amount1Desired;
            uint256 amount0Min;
            uint256 amount1Min;
            uint256 token0;
            uint256 token1;

            // calculate sale amount of tokens needed for launching pool
            if (_poolKey().token0 == RAISE_TOKEN) {
                amount0Desired = totalRaised;
                amount0Min = totalRaised;
                amount1Desired = _saleAmountNeeded(totalRaised);
            } else {
                amount0Desired = _saleAmountNeeded(totalRaised);
                amount1Desired = totalRaised;
                amount1Min = totalRaised;
            }

            // actually deploy liquidity to uniswap pool
            (liquidity, token0, token1) = addLiquidity(AddLiquidityParams({
                pool: IUniswapV3Pool(_uniV3PoolAddress()),
                amount0Desired: amount0Desired,
                amount1Desired: amount1Desired,
                amount0Min: amount0Min,
                amount1Min: amount1Min
            }));

            emit PoolLaunch(_uniV3PoolAddress(), liquidity, token0, token1);
        }

        IILOManager.Project memory _project = MANAGER.project(_uniV3PoolAddress());

        // assigning vests for the project configuration
        for (uint256 index = 0; index < _project.projectVestConfigs.length; index++) {
            uint256 tokenId;
            IILOManager.ProjectVestConfig memory projectConfig = _project.projectVestConfigs[index];
            // mint nft for recipient
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

            emit Buy(projectConfig.recipient, tokenId, 0, liquidityShares);
        }

        // transfer back leftover sale token to project admin
        _refundProject(_project.admin);

        _launchSucceeded = true;
    }

    modifier refundable() {
        if (!_refundTriggered) {
            // if ilo pool is lauch sucessfully, we can not refund anymore
            require(!_launchSucceeded);
            IILOManager.Project memory _project = MANAGER.project(_uniV3PoolAddress());
            require(block.timestamp >= _project.refundDeadline);

            _refundTriggered = true;
        }
        _;
    }

    /// @inheritdoc IILOPool
    function claimRefund(uint256 tokenId) external override refundable() isAuthorizedForToken(tokenId) {
        uint256 refundAmount = _positions[tokenId].raiseAmount;

        delete _positions[tokenId];
        delete _positionVests[tokenId];
        _burn(tokenId);

        TransferHelper.safeTransfer(RAISE_TOKEN, ownerOf(tokenId), refundAmount);
        emit UserRefund(ownerOf(tokenId), refundAmount);
    }

    /// @inheritdoc IILOPool
    function claimProjectRefund(address projectAdmin) external override refundable() OnlyManager() returns(uint256 refundAmount) {
        return _refundProject(projectAdmin);
    }

    function _refundProject(address projectAdmin) internal returns (uint256 refundAmount) {
        refundAmount = IERC20(SALE_TOKEN).balanceOf(address(this));
        if (refundAmount > 0) {
            TransferHelper.safeTransfer(SALE_TOKEN, projectAdmin, refundAmount);
            emit ProjectRefund(projectAdmin, refundAmount);
        }
    }

    /// @notice returns amount of sale token that has already been sold
    function totalSold() public view returns (uint256) {
        return _saleAmountNeeded(totalRaised);
    }

    /// @notice return sale token amount needed for the raiseAmount.
    /// @dev sale token amount is rounded up
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

    /// @notice calculate amount of liquidity unlocked for claim
    /// @param tokenId nft token id of position
    /// @return liquidityUnlocked amount of unlocked liquidity
    function _unlockedLiquidity(uint256 tokenId) internal view override returns (uint128 liquidityUnlocked) {
        PositionVest storage _positionVest = _positionVests[tokenId];
        liquidityUnlocked = uint128(FullMath.mulDiv(
                _positionVest.totalLiquidity,
                _unlockedSharesBPS(_positionVest.schedule), 
                BPS
            ));
    }

    /// @notice assign vesting schedule for position
    function _assignVestingSchedule(uint256 nftId, LinearVest[] storage vestingSchedule) internal {
        _positionVests[nftId].schedule = vestingSchedule;
    }

    /// @notice update total liquidity for vesting position
    /// vesting liquidity of position only changes when investor buy ilo
    function _updateVestingLiquidity(uint256 nftId, uint128 liquidity) internal {
        _positionVests[nftId].totalLiquidity = liquidity;
    }

    /// @notice calculate the amount left after deduct fee
    /// @param amount0 the amount of token0 before deduct fee
    /// @param amount1 the amount of token1 before deduct fee
    /// @return amount0Left the amount of token0 after deduct fee
    /// @return amount1Left the amount of token1 after deduct fee
    function _deductFees(uint256 amount0, uint256 amount1, uint16 feeBPS) internal pure 
        returns (
            uint256 amount0Left, 
            uint256 amount1Left
        ) {
        amount0Left = amount0 - FullMath.mulDiv(amount0, feeBPS, BPS);
        amount1Left = amount1 - FullMath.mulDiv(amount1, feeBPS, BPS);
    }

    function unlockedLiquidity(uint256 tokenId) external view returns(uint128) {
        return _unlockedLiquidity(tokenId);
    }

    function claimableLiquidity(uint256 tokenId) external view returns(uint128) {
        return _claimableLiquidity(tokenId);
    }

    function claimedLiquidity(uint256 tokenId) external view returns(uint128) {
        return  _positionVests[tokenId].totalLiquidity - _positions[tokenId].liquidity;
    }

    function _claimableLiquidity(uint256 tokenId) internal view override returns (uint128) {
        uint128 liquidityClaimed = _positionVests[tokenId].totalLiquidity - _positions[tokenId].liquidity;
        uint128 liquidityUnlocked = _unlockedLiquidity(tokenId);
        return liquidityClaimed < liquidityUnlocked ? liquidityUnlocked - liquidityClaimed : 0;
    }
}
