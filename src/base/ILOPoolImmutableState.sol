// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

import '../interfaces/IILOPoolImmutableState.sol';
import '../libraries/PoolAddress.sol';
import '../interfaces/IILOManager.sol';

/// @title Immutable state
/// @notice Immutable state used by periphery contracts
abstract contract ILOPoolImmutableState is IILOPoolImmutableState {
    /// @inheritdoc IILOPoolImmutableState
    address public immutable override factory;
    /// @inheritdoc IILOPoolImmutableState
    address public immutable override WETH9;

    IILOManager MANAGER;
    address RAISE_TOKEN;
    address SALE_TOKEN;
    uint16 constant BPS = 10000;
    int24 TICK_LOWER;
    int24 TICK_UPPER;
    uint160 SQRT_RATIO_X96;
    uint160 SQRT_RATIO_LOWER_X96;
    uint160 SQRT_RATIO_UPPER_X96;
    uint16 PLATFORM_FEE; // BPS 10000
    uint16 INVESTOR_SHARES; // BPS 10000
    PoolAddress.PoolKey private _cachedPoolKey;
    address private _cachedUniV3PoolAddress;

    constructor(address _factory, address _WETH9) {
        factory = _factory;
        WETH9 = _WETH9;
    }

    function _cachePoolKey(PoolAddress.PoolKey memory poolKey) internal {
        _cachedPoolKey = poolKey;
    }

    function _poolKey() internal view returns (PoolAddress.PoolKey memory) {
        return _cachedPoolKey;
    }

    function _cacheUniV3PoolAddress(address uniV3PoolAddress) internal {
        _cachedUniV3PoolAddress = uniV3PoolAddress;
    }

    function _uniV3PoolAddress() internal view returns (address) {
        return _cachedUniV3PoolAddress;
    }
}
