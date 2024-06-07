// SPDX-License-Identifier: BUSL-1.1 

pragma solidity =0.7.6;
pragma abicoder v2;

import '../interfaces/IILOSale.sol';

abstract contract ILOSale is IILOSale {
    SaleInfo saleInfo;

    modifier duringSale {
        require(block.timestamp > saleInfo.start && block.timestamp < saleInfo.end, "ST");
        _;
    }
}
