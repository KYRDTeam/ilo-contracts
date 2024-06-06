// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

import '../interfaces/IILOPoolImmutableState.sol';
import '../libraries/PoolAddress.sol';

/// @title Immutable state
/// @notice Immutable state used by periphery contracts
abstract contract ILOPoolImmutableState is IILOPoolImmutableState {
    /// @inheritdoc IILOPoolImmutableState
    address public override WETH9;

    uint16 constant BPS = 10000;
    address public override MANAGER;
    address public override RAISE_TOKEN;
    address public override SALE_TOKEN;
    int24 public override TICK_LOWER;
    int24 public override TICK_UPPER;
    uint160 internal SQRT_RATIO_X96;
    uint160 internal SQRT_RATIO_LOWER_X96;
    uint160 internal SQRT_RATIO_UPPER_X96;
    uint16 public override PLATFORM_FEE; // BPS 10000
    uint16 public override PERFORMANCE_FEE; // BPS 10000
    uint16 public override INVESTOR_SHARES; // BPS 10000
    PoolAddress.PoolKey internal _cachedPoolKey;
    address internal _cachedUniV3PoolAddress;

    // function _cachePoolKey(PoolAddress.PoolKey memory poolKey) internal {
    //     _cachedPoolKey = poolKey;
    // }

    // function _cachedPoolKey internal view returns (PoolAddress.PoolKey memory) {
    //     return _cachedPoolKey;
    // }

    // function _cacheUniV3PoolAddress(address uniV3PoolAddress) internal {
    //     _cachedUniV3PoolAddress = uniV3PoolAddress;
    // }

    // function _cachedUniV3PoolAddress internal view returns (address) {
    //     return _cachedUniV3PoolAddress;
    // }
}
