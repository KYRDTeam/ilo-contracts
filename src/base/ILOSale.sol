// SPDX-License-Identifier: MIT 

pragma solidity =0.7.6;
pragma abicoder v2;

import '../interfaces/IILOSale.sol';

abstract contract ILOSale is IILOSale {
    struct SaleInfo {
        uint256 hardCap; // total amount of raise tokens
        uint256 softCap; // minimum amount of raise token needed for launch pool
        uint256 maxCapPerUser; // TODO: user tiers
        uint64 start;
        uint64 end;
        uint256 maxSaleAmount; // maximum amount of sale tokens
    }

    SaleInfo saleInfo;

    /// @inheritdoc IILOSale
    function buy(uint256 raiseAmount, address recipient) external virtual override returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amountAdded0,
            uint256 amountAdded1
        );
    
    modifier beforeSale {
        require(block.timestamp < saleInfo.start);
        _;
    }

    modifier afterSale {
        require(block.timestamp > saleInfo.end);
        _;
    }

    modifier duringSale {
        require(block.timestamp > saleInfo.start && block.timestamp < saleInfo.end);
        _;
    }
}