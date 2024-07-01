// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.7.6;
pragma abicoder v2;

import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';
import '@uniswap/v3-core/contracts/libraries/FixedPoint128.sol';
import '@uniswap/v3-core/contracts/libraries/FullMath.sol';

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';

import './interfaces/IILOPool.sol';
import './libraries/PositionKey.sol';
import './libraries/SqrtPriceMathPartial.sol';
import './base/ILOVest.sol';
import './base/LiquidityManagement.sol';
import './base/ILOPoolImmutableState.sol';
import './base/Initializable.sol';
import './base/Multicall.sol';
import "./base/ILOWhitelist.sol";

/// @title NFT positions
/// @notice Wraps Uniswap V3 positions in the ERC721 non-fungible token interface
contract ILOPool is
    ERC721,
    IILOPool,
    ILOWhitelist,
    ILOVest,
    Initializable,
    Multicall,
    LiquidityManagement
{
    SaleInfo saleInfo;

    /// @dev when lauch successfully we can not refund anymore
    bool private _launchSucceeded;

    /// @dev when refund triggered, we can not launch anymore
    bool private _refundTriggered;

    /// @dev The token ID position data
    mapping(uint256 => Position) private _positions;
    VestingConfig[] private _vestingConfigs;

    /// @dev The ID of the next token that will be minted. Skips 0
    uint256 private _nextId;
    uint128 private _totalInitialLiquidity;
    uint256 totalRaised;
    constructor() ERC721('', '') {
        _disableInitialize();
    }

    function name() public pure override(ERC721, IERC721Metadata) returns (string memory) {
        return 'KRYSTAL ILOPool V1';
    }

    function symbol() public pure override(ERC721, IERC721Metadata) returns (string memory) {
        return 'KRYSTAL-ILO-V1';
    }

    function initialize(InitPoolParams calldata params) external override whenNotInitialized() {
        _nextId = 1;
        // initialize imutable state
        PROJECT_ID = params.projectId;
        MANAGER = IILOManager(msg.sender);
        IILOManager.Project memory _project = IILOManager(MANAGER).project(params.projectId);

        RAISE_TOKEN = _project.raiseToken;
        TICK_LOWER = params.tickLower;
        TICK_UPPER = params.tickUpper;
        SQRT_RATIO_X96 = _project.initialPoolPriceX96;
        IMPLEMENTATION = params.implementation;
        POOL_INDEX = params.poolIndex;
        require(_sqrtRatioLowerX96() <  _project.initialPoolPriceX96 &&  _project.initialPoolPriceX96 < _sqrtRatioUpperX96(), "RANGE");

        // rounding up to make sure that the number of sale token is enough for sale
        // initialize sale
        saleInfo = SaleInfo({
            maxRaise: params.maxRaise,
            minRaise: params.minRaise,
            start: params.start,
            end: params.end
        });

        _validateSharesAndVests(_project.launchTime, params.vestingConfigs);
        // initialize vesting
        for (uint256 index = 0; index < params.vestingConfigs.length; index++) {
            _vestingConfigs.push(params.vestingConfigs[index]);
        }

        emit ILOPoolInitialized(
            params.projectId,
            TICK_LOWER,
            TICK_UPPER,
            saleInfo,
            params.vestingConfigs
        );
    }

    /// @inheritdoc IILOPool
    function positions(uint256 tokenId)
        external
        view
        override
        returns (
            uint128 liquidity,
            uint256 raiseAmount,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128
        )
    {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        return (
            _positionVests[tokenId].totalLiquidity > 0 ? _positions[tokenId].liquidity : _calculateTotalVestLiquidity(tokenId),
            _positions[tokenId].raiseAmount,
            _positions[tokenId].feeGrowthInside0LastX128,
            _positions[tokenId].feeGrowthInside1LastX128
        );
    }

    /// @inheritdoc IILOSale
    function buy(uint256 raiseAmount, address recipient)
        external override 
        returns (
            uint256 tokenId
        )
    {
        require(block.timestamp > saleInfo.start && block.timestamp < saleInfo.end, "SLT");
        require(raiseAmount > 0, "ZA");
        // check if raise amount over capacity
        require(saleInfo.maxRaise - totalRaised >= raiseAmount, "HC");
        totalRaised += raiseAmount;

        // if investor already have a position, just increase raise amount and liquidity
        // otherwise, mint new nft for investor and assign vesting schedules
        if (balanceOf(recipient) == 0) {
            _mint(recipient, (tokenId = _nextId++));
            _positionVests[tokenId].schedule = _vestingConfigs[0].schedule;
        } else {
            tokenId = tokenOfOwnerByIndex(recipient, 0);
        }

        Position storage _position = _positions[tokenId];

        uint256 _allocation = allocation(recipient);
        // we need to check `_position.raiseAmount < _allocation`
        // because project admin can change whitelist during sale. 
        // so, technicaly, `_position.raiseAmount` can bigger than `_allocation`
        // second reason is to avoid overflow of subtraction.
        require(_position.raiseAmount < _allocation && raiseAmount <= _allocation - _position.raiseAmount, "UC");
        _position.raiseAmount += raiseAmount;

        // transfer fund into contract
        TransferHelper.safeTransferFrom(RAISE_TOKEN, msg.sender, address(this), raiseAmount);

        emit Buy(recipient, tokenId, raiseAmount);
    }

    modifier isAuthorizedForToken(uint256 tokenId) {
        require(_isApprovedOrOwner(msg.sender, tokenId), 'UA');
        _;
    }

    /// @inheritdoc IILOPool
    function claim(uint256 tokenId)
        external
        override
        isAuthorizedForToken(tokenId)
        returns (uint256 amount0, uint256 amount1)
    {
        // only can claim if the launch is successfully
        require(_launchSucceeded, "PNL");
        _fillPositionLiquidity(tokenId);
        // calculate amount of unlocked liquidity for the position
        uint128 liquidity2Claim = _claimableLiquidity(tokenId);
        IUniswapV3Pool pool = IUniswapV3Pool(_cachedUniV3PoolAddress);
        Position storage position = _positions[tokenId];
        uint256 fees0;
        uint256 fees1;
        uint128 amountCollected0;
        uint128 amountCollected1;
        {
            IILOManager.Project memory _project = IILOManager(MANAGER).project(PROJECT_ID);
            {
                uint128 positionLiquidity = position.liquidity;
                require(positionLiquidity >= liquidity2Claim);

                // get amount of token0 and token1 that pool will return for us
                (amount0, amount1) = pool.burn(TICK_LOWER, TICK_UPPER, liquidity2Claim);
                emit DecreaseLiquidity(tokenId, liquidity2Claim, amount0, amount1);

                // calculate amount of fees that position generated
                bytes32 positionKey = PositionKey.compute(address(this), TICK_LOWER, TICK_UPPER);
                (, uint256 feeGrowthInside0LastX128, uint256 feeGrowthInside1LastX128, , ) = pool.positions(positionKey);
                fees0 = FullMath.mulDiv(
                                    feeGrowthInside0LastX128 - position.feeGrowthInside0LastX128,
                                    positionLiquidity,
                                    FixedPoint128.Q128
                                );
                
                fees1 = FullMath.mulDiv(
                                    feeGrowthInside1LastX128 - position.feeGrowthInside1LastX128,
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

            if(_project.platformFee > 0) {
                // get amount of token0 and token1 after deduct platform fee
                (amount0, amount1) = _deductFees(amount0, amount1, _project.platformFee);
            }

            if(_project.performanceFee > 0) {
                // amount of fees after deduct performance fee
                (fees0, fees1) = _deductFees(fees0, fees1, _project.performanceFee);
            }

            // fees is combined with liquidity token amount to return to the user
            amount0 += fees0;
            amount1 += fees1;

            // if platformFee and performanceFee is 0, amountCollected might be smaller than amount due to rounding down in uniswap v3 pool
            amount0 = amount0 > amountCollected0 ? amountCollected0 : amount0;
            amount1 = amount1 > amountCollected1 ? amountCollected1 : amount1;

            // subtraction is safe because we checked positionLiquidity is gte liquidity2Claim
            position.liquidity -= liquidity2Claim;
            emit Collect(tokenId, address(this), amountCollected0, amountCollected1);
        }


        // transfer token for user
        TransferHelper.safeTransfer(_cachedPoolKey.token0, ownerOf(tokenId), amount0);
        TransferHelper.safeTransfer(_cachedPoolKey.token1, ownerOf(tokenId), amount1);

        emit Claim(ownerOf(tokenId), tokenId,liquidity2Claim, amount0, amount1, position.feeGrowthInside0LastX128, position.feeGrowthInside1LastX128, fees0, fees1);

        address feeTaker = IILOManager(MANAGER).FEE_TAKER();
        // transfer fee to fee taker
        TransferHelper.safeTransfer(_cachedPoolKey.token0, feeTaker, amountCollected0-amount0);
        TransferHelper.safeTransfer(_cachedPoolKey.token1, feeTaker, amountCollected1-amount1);
    }

    /// @notice this function is used to fill liquidity for the position only in the first time user claim
    function _fillPositionLiquidity(uint256 tokenId) internal {
        if (_positionVests[tokenId].totalLiquidity == 0) {
            uint128 positionLiquidity = _calculateTotalVestLiquidity(tokenId);
            _positionVests[tokenId].totalLiquidity = positionLiquidity;
            _positions[tokenId].liquidity = positionLiquidity;
        }
    }

    modifier OnlyManager() {
        require(msg.sender == address(MANAGER), "UA");
        _;
    }

    /// @inheritdoc IILOPool
    function launch(string calldata projectId, 
        address uniV3PoolAddress, 
        PoolAddress.PoolKey calldata poolKey
    ) external override OnlyManager() {
        require(!_launchSucceeded, "PL");
        // when refund triggered, we can not launch pool anymore
        require(!_refundTriggered, "IRF");
        // make sure that soft cap requirement match
        require(totalRaised >= saleInfo.minRaise, "SC");
        
        // cache uniswap v3 pool info
        _cachedUniV3PoolAddress = uniV3PoolAddress;
        _cachedPoolKey = poolKey;
        
        uint128 liquidity;
        IILOManager.Project memory _project = IILOManager(MANAGER).project(projectId);
        {
            if (poolKey.token0 == RAISE_TOKEN) {
                // if token0 is raise token, we need to flip the tick range
                _flipPriceAndTicks();
                liquidity = LiquidityAmounts.getLiquidityForAmount0(SQRT_RATIO_X96, _sqrtRatioUpperX96(), totalRaised);
            } else {
                liquidity = LiquidityAmounts.getLiquidityForAmount1(_sqrtRatioLowerX96(), SQRT_RATIO_X96, totalRaised);
            }

            // actually deploy liquidity to uniswap pool
            (uint256 amount0, uint256 amount1) = addLiquidity(AddLiquidityParams({
                pool: IUniswapV3Pool(uniV3PoolAddress),
                liquidity: liquidity,
                projectAdmin: _project.admin
            }));

            _totalInitialLiquidity = liquidity;

            emit PoolLaunch(uniV3PoolAddress, liquidity, amount0, amount1);
        }


        // assigning vests for the project configuration
        for (uint256 index = 1; index < _vestingConfigs.length; index++) {
            uint256 tokenId;
            VestingConfig memory projectConfig = _vestingConfigs[index];
            // mint nft for recipient
            _mint(projectConfig.recipient, (tokenId = _nextId++));
            uint128 liquidityShares = uint128(FullMath.mulDiv(liquidity, projectConfig.shares, BPS)); // BPS = 10000

            Position storage _position = _positions[tokenId];
            _position.liquidity = liquidityShares;
            _positionVests[tokenId].totalLiquidity = liquidityShares;

            // assign vesting schedule
            LinearVest[] storage schedule = _positionVests[tokenId].schedule;
            for (uint256 i = 0; i < projectConfig.schedule.length; i++) {
                schedule.push(projectConfig.schedule[i]);
            }

            emit Buy(projectConfig.recipient, tokenId, 0);
        }

        _launchSucceeded = true;
    }

    modifier refundable() {
        if (!_refundTriggered) {
            // if ilo pool is lauch sucessfully, we can not refund anymore
            require(!_launchSucceeded, "PL");
            require(block.timestamp > saleInfo.end, "SLT");
            if (totalRaised > saleInfo.minRaise) {
                IILOManager.Project memory _project = IILOManager(MANAGER).project(PROJECT_ID);
                require(block.timestamp >= _project.refundDeadline, "RFT");
            }

            _refundTriggered = true;
        }
        _;
    }

    function burn(uint256 tokenId) external isAuthorizedForToken(tokenId) {
        _burn(tokenId);
    }

    /// @inheritdoc ERC721
    function _burn(uint256 tokenId) internal override {
        delete _positions[tokenId];
        delete _positionVests[tokenId];
        super._burn(tokenId);
    }

    /// @inheritdoc IILOPool
    function claimRefund(uint256 tokenId) external override refundable() isAuthorizedForToken(tokenId) {
        uint256 refundAmount = _positions[tokenId].raiseAmount;
        address tokenOwner = ownerOf(tokenId);

        _burn(tokenId);

        TransferHelper.safeTransfer(RAISE_TOKEN, tokenOwner, refundAmount);
        emit UserRefund(tokenOwner, tokenId,refundAmount);
    }

    
    /// @notice calculate amount of liquidity unlocked for claim
    /// @param totalLiquidity total liquidity to vest
    /// @param vestingSchedule the vesting schedule
    function _unlockedLiquidity(uint128 totalLiquidity, LinearVest[] storage vestingSchedule) internal view returns (uint128 liquidityUnlocked) {
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
                liquidityUnlocked += uint128(FullMath.mulDiv(
                    vest.shares, 
                    totalLiquidity, 
                    BPS
                ));
            } else {
                liquidityUnlocked += uint128(FullMath.mulDiv(
                    vest.shares * totalLiquidity, 
                    block.timestamp - vest.start, 
                    (vest.end - vest.start) * BPS
                ));
            }
        }
    }

    /// @inheritdoc ERC721
    function _beforeTokenTransfer(address from, address, uint256) internal view override {
        require(from == address(0) || block.timestamp > saleInfo.end, "SLT");
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

    /// @inheritdoc IILOVest
    function vestingStatus(uint256 tokenId) external view override returns (
        uint128 unlockedLiquidity,
        uint128 claimedLiquidity
    ) {
        PositionVest storage _positionVest = _positionVests[tokenId];
        uint128 totalLiquidity = _positionVest.totalLiquidity;
        if (totalLiquidity == 0) {
            totalLiquidity = _calculateTotalVestLiquidity(tokenId);
        }
        unlockedLiquidity = _unlockedLiquidity(totalLiquidity, _positionVest.schedule);
        claimedLiquidity = _positionVests[tokenId].totalLiquidity - _positions[tokenId].liquidity;
    }

    /// @notice calculate total liquidity for vesting if user not make any claim
    /// this function only can be called after launch
    function _calculateTotalVestLiquidity(uint256 tokenId) internal view returns(uint128 totalLiquidity) {
        if(!_launchSucceeded) return 0;
        uint128 totalInvestorLiquidity = uint128(FullMath.mulDiv(_totalInitialLiquidity, _vestingConfigs[0].shares, BPS));
        totalLiquidity = uint128(FullMath.mulDiv(totalInvestorLiquidity, _positions[tokenId].raiseAmount, totalRaised));
    }

    function _claimableLiquidity(uint256 tokenId) internal view returns (uint128) {
        uint128 liquidityClaimed = _positionVests[tokenId].totalLiquidity - _positions[tokenId].liquidity;
        uint128 liquidityUnlocked = _unlockedLiquidity(_positionVests[tokenId].totalLiquidity, _positionVests[tokenId].schedule);
        return liquidityClaimed < liquidityUnlocked ? liquidityUnlocked - liquidityClaimed : 0;
    }

    modifier onlyProjectAdmin() override {
        IILOManager.Project memory _project = IILOManager(MANAGER).project(PROJECT_ID);
        require(msg.sender == _project.admin, "UA");
        _;
    }

}
