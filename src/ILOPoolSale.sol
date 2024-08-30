// SPDX-License-Identifier: BUSL-1.1

pragma solidity =0.7.6;
pragma abicoder v2;

import { ILOPoolBase, IILOPoolBase } from './base/ILOPoolBase.sol';
import { ILOWhitelist } from './base/ILOWhitelist.sol';
import { IILOPoolSale } from './interfaces/IILOPoolSale.sol';
import { IILOManager } from './interfaces/IILOManager.sol';
import { TransferHelper } from './libraries/TransferHelper.sol';
import { PoolAddress } from './libraries/PoolAddress.sol';
import { FullMath } from '@uniswap/v3-core/contracts/libraries/FullMath.sol';
import { ReentrancyGuard } from '@openzeppelin/contracts/utils/ReentrancyGuard.sol';

contract ILOPoolSale is
    ILOPoolBase,
    IILOPoolSale,
    ILOWhitelist,
    ReentrancyGuard
{
    uint64 public override SALE_START;
    uint64 public override SALE_END;
    uint256 public override MIN_RAISE;
    uint256 public override MAX_RAISE;
    uint256 public override TOTAL_RAISED;

    LinearVest[] private _vestingSchedule;

    modifier onlyProjectAdmin() override {
        IILOManager.Project memory _project = IILOManager(MANAGER).project(
            PROJECT_ID
        );
        require(msg.sender == _project.admin, 'UA');
        _;
    }

    modifier duringSale() {
        require(SALE_START <= block.timestamp, 'ST');
        require(SALE_END > block.timestamp, 'ST');
        _;
    }

    modifier beforeSale() {
        require(SALE_START > block.timestamp, 'ST');
        _;
    }

    function initialize(InitParams calldata params) external override {
        _validateVestSchedule(params.vestingSchedule);
        _initialize(params.baseParams);

        for (uint256 i = 0; i < params.vestingSchedule.length; i++) {
            _vestingSchedule.push(params.vestingSchedule[i]);
        }

        (SALE_START, SALE_END, MIN_RAISE, MAX_RAISE) = (
            params.saleParams.start,
            params.saleParams.end,
            params.saleParams.minRaise,
            params.saleParams.maxRaise
        );

        emit ILOPoolSaleInitialized(
            params.baseParams,
            params.saleParams,
            params.vestingSchedule
        );
    }

    function buy(
        uint256 raiseAmount,
        address recipient
    )
        external
        override
        duringSale
        whenNotCancelled
        nonReentrant
        returns (uint256 tokenId)
    {
        require(raiseAmount > 0, 'ZA');

        // transfer fund into contract
        TransferHelper.safeTransferFrom(
            PAIR_TOKEN,
            msg.sender,
            address(this),
            raiseAmount
        );

        // check if raise amount over capacity
        require(MAX_RAISE - TOTAL_RAISED >= raiseAmount, 'MR');
        TOTAL_RAISED += raiseAmount;

        // if investor already have a position, just increase raise amount and liquidity
        // otherwise, mint new nft for investor and assign vesting schedules
        if (balanceOf(recipient) == 0) {
            _mint(recipient, (tokenId = _nextId++));
            _positionVests[tokenId].schedule = _vestingSchedule;
        } else {
            tokenId = tokenOfOwnerByIndex(recipient, 0);
        }

        Position storage _position = _positions[tokenId];

        uint256 _allocation = allocation(recipient);
        // we need to check `_position.raiseAmount < _allocation`
        // because project admin can change whitelist during sale.
        // so, technicaly, `_position.raiseAmount` can bigger than `_allocation`
        // second reason is to avoid overflow of subtraction.
        require(
            _position.raiseAmount < _allocation &&
                raiseAmount <= _allocation - _position.raiseAmount,
            'UC'
        );
        _position.raiseAmount += raiseAmount;

        emit Buy(recipient, tokenId, raiseAmount);
    }

    /// @inheritdoc IILOPoolBase
    function launch(
        address uniV3PoolAddress,
        PoolAddress.PoolKey calldata poolKey,
        uint160 sqrtPriceX96
    ) external override onlyManager onlyInitializedProject whenNotCancelled {
        if (block.timestamp < SALE_END) {
            revert('ST');
        }
        if (TOTAL_RAISED < MIN_RAISE) {
            revert('MR');
        }

        // transfer all raised fund to project admin
        IILOManager.Project memory _project = IILOManager(MANAGER).project(
            PROJECT_ID
        );
        TransferHelper.safeTransfer(PAIR_TOKEN, _project.admin, TOTAL_RAISED);

        // launch liquidity
        uint128 liquidity = _launchLiquidity(
            uniV3PoolAddress,
            poolKey,
            sqrtPriceX96,
            FullMath.mulDiv(_tokenAmount, TOTAL_RAISED, MAX_RAISE)
        );
        emit PoolSaleLaunched(TOTAL_RAISED, liquidity);
    }

    function claim(
        uint256 tokenId
    )
        external
        override
        afterLaunch
        nonReentrant
        returns (uint256 amount0, uint256 amount1)
    {
        _fillLiquidityForPosition(tokenId);
        return _claim(tokenId);
    }

    function cancel() external override onlyManager beforeSale {
        _cancel();
    }

    function claimRefund(
        uint256 tokenId
    )
        external
        override
        isAuthorizedForToken(tokenId)
        nonReentrant
        returns (uint256 refundAmount)
    {
        require(_refundable(), 'NR');
        Position storage _position = _positions[tokenId];
        refundAmount = _position.raiseAmount;
        require(refundAmount > 0, 'ZA');
        address recipient = ownerOf(tokenId);
        _burn(tokenId);
        TransferHelper.safeTransfer(PAIR_TOKEN, recipient, refundAmount);
        emit Refund(recipient, tokenId, refundAmount);
    }

    function tokenSoldAmount() public view override returns (uint256) {
        return (_tokenAmount * TOTAL_RAISED) / MAX_RAISE;
    }
    function name() public pure override returns (string memory) {
        return 'KRYSTAL ILOPoolSale V3';
    }

    function symbol() public pure override returns (string memory) {
        return 'KRYSTAL-ILO-SALE-V3';
    }

    function _initImplementation() internal override {
        IMPLEMENTATION = IILOManager(MANAGER).ILO_POOL_SALE_IMPLEMENTATION();
    }

    function _refundable() internal returns (bool) {
        if (CANCELLED) {
            return true;
        }

        IILOManager.Project memory _project = IILOManager(MANAGER).project(
            PROJECT_ID
        );

        if (
            // when project is cancelled
            _project.status == IILOManager.ProjectStatus.CANCELLED ||
            // when not cancelled yet, but sale end and not reach min raise
            (block.timestamp > SALE_END && TOTAL_RAISED < MIN_RAISE)
        ) {
            _cancel();

            // callback to cancel project
            IILOManager(MANAGER).onPoolSaleFail(PROJECT_ID);
            return true;
        }
        return false;
    }

    function _fillLiquidityForPosition(uint256 tokenId) private {
        PositionVest storage _positionVest = _positionVests[tokenId];
        if (_positionVest.totalLiquidity > 0) {
            return;
        }
        Position storage _position = _positions[tokenId];
        uint128 liquidity = uint128(
            FullMath.mulDiv(
                _totalInitialLiquidity,
                _position.raiseAmount,
                TOTAL_RAISED
            )
        );
        _position.liquidity = liquidity;
        _positionVest.totalLiquidity = liquidity;
    }
}
