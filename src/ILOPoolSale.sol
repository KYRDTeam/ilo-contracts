// SPDX-License-Identifier: BUSL-1.1

pragma solidity =0.7.6;
pragma abicoder v2;

import {ILOPoolBase} from './base/ILOPoolBase.sol';
import {ILOWhitelist} from './base/ILOWhitelist.sol';
import {IILOPoolSale} from './interfaces/IILOPoolSale.sol';
import {IILOManager} from './interfaces/IILOManager.sol';
import {TransferHelper} from './libraries/TransferHelper.sol';
contract ILOPoolSale is ILOPoolBase, IILOPoolSale, ILOWhitelist {
    bool public override CANCELLED;
    uint64 public override SALE_START;
    uint64 public override SALE_END;
    uint256 public override MIN_RAISE;
    uint256 public override MAX_RAISE;
    uint256 public override TOTAL_RAISED;

    VestingConfig private _vestingConfig;

    modifier onlyProjectAdmin() override {
        IILOManager.Project memory _project = IILOManager(MANAGER).project(
            PROJECT_ID
        );
        require(msg.sender == _project.admin, 'UA');
        _;
    }

    modifier duringSale() {
        require(SALE_START <= block.timestamp, 'BS');
        require(SALE_END > block.timestamp, 'ES');
        _;
    }

    function initialize(InitParams calldata params) external override {
        _initialize(params.poolParams);
        require(params.poolParams.vestingConfigs.length == 1, 'VC');
        _vestingConfig = params.poolParams.vestingConfigs[0];
        (SALE_START, SALE_END, MIN_RAISE, MAX_RAISE) = (
            params.saleParams.start,
            params.saleParams.end,
            params.saleParams.minRaise,
            params.saleParams.maxRaise
        );
    }

    function name() public pure override returns (string memory) {
        return 'KRYSTAL ILOPoolSale V3';
    }

    function symbol() public pure override returns (string memory) {
        return 'KRYSTAL-ILO-SALE-V3';
    }

    function tokenSoldAmount() public view override returns (uint256) {
        return (_tokenAmount * TOTAL_RAISED) / MAX_RAISE;
    }

    function cancel() public override OnlyManager {
        require(!CANCELLED, 'CANCELLED');
        CANCELLED = true;
        emit PoolSaleCancelled();
    }

    function buy(
        uint256 raiseAmount,
        address recipient
    ) external override duringSale returns (uint256 tokenId) {
        require(raiseAmount > 0, 'ZA');
        // check if raise amount over capacity
        uint256 totalRaised = TOTAL_RAISED;
        require(MAX_RAISE - totalRaised >= raiseAmount, 'MR');
        totalRaised += raiseAmount;
        TOTAL_RAISED = totalRaised;

        // if investor already have a position, just increase raise amount and liquidity
        // otherwise, mint new nft for investor and assign vesting schedules
        if (balanceOf(recipient) == 0) {
            _mint(recipient, (tokenId = _nextId++));
            _positionVests[tokenId].schedule = _vestingConfig.schedule;
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

        // transfer fund into contract
        TransferHelper.safeTransferFrom(
            PAIR_TOKEN,
            msg.sender,
            address(this),
            raiseAmount
        );

        emit Buy(recipient, tokenId, raiseAmount);
    }
}
