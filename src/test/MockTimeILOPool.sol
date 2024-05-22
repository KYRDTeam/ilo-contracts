// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;
pragma abicoder v2;

import '../ILOPool.sol';

contract MockTimeILOPool is ILOPool {
    uint256 time;

    constructor(
        address _factory,
        address _WETH9
    ) ILOPool(_factory, _WETH9) {}

    function _blockTimestamp() internal view override returns (uint256) {
        return time;
    }

    function setTime(uint256 _time) external {
        time = _time;
    }
}
