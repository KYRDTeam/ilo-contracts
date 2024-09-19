// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.7.6;
pragma abicoder v2;

import { IILOPoolBase } from './IILOPoolBase.sol';
import { IILOWhitelist } from './IILOWhitelist.sol';

interface IILOPoolSale is IILOPoolBase, IILOWhitelist {
    struct SaleParams {
        uint64 start;
        uint64 end;
        uint256 minRaise;
        uint256 maxRaise;
    }

    struct InitParams {
        InitPoolBaseParams baseParams;
        SaleParams saleParams;
        LinearVest[] vestingSchedule;
    }

    event ILOPoolSaleInitialized(
        InitPoolBaseParams baseParams,
        SaleParams saleParams,
        LinearVest[] vestingSchedule
    );

    event PoolSaleCancelled();

    event PoolSaleLaunched(uint256 totalRaised, uint128 liquidity);

    function initialize(InitParams calldata params) external;

    /// @notice this function is for investor buying ILO
    function buy(
        uint256 raiseAmount,
        address recipient
    ) external returns (uint256 tokenId);

    function claimRefund(
        uint256 tokenId
    ) external returns (uint256 refundAmount);

    function SALE_START() external view returns (uint64);
    function SALE_END() external view returns (uint64);
    function MIN_RAISE() external view returns (uint256);
    function MAX_RAISE() external view returns (uint256);
    function TOTAL_RAISED() external view returns (uint256);
    function tokenSoldAmount() external view returns (uint256);
    function refundable() external view returns (bool);
}
