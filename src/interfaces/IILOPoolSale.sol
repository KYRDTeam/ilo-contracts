// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.7.6;
pragma abicoder v2;

import {IILOVest} from './IILOVest.sol';
import {IILOPoolBase} from './IILOPoolBase.sol';

interface IILOPoolSale {
    event ILOPoolSaleInitialized(
        IILOPoolBase.InitPoolParams poolParams,
        IILOPoolSale.SaleParams saleParams
    );

    event PoolSaleCancelled();

    struct SaleParams {
        uint64 start;
        uint64 end;
        uint256 minRaise;
        uint256 maxRaise;
    }

    struct InitParams {
        IILOPoolBase.InitPoolParams poolParams;
        SaleParams saleParams;
    }

    function initialize(InitParams calldata params) external;

    function CANCELLED() external view returns (bool);
    function SALE_START() external view returns (uint64);
    function SALE_END() external view returns (uint64);
    function MIN_RAISE() external view returns (uint256);
    function MAX_RAISE() external view returns (uint256);
    function TOTAL_RAISED() external view returns (uint256);
    function tokenSoldAmount() external view returns (uint256);

    function cancel() external;
    /// @notice this function is for investor buying ILO
    function buy(
        uint256 raiseAmount,
        address recipient
    ) external returns (uint256 tokenId);
}
