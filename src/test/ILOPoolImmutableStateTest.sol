// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

import '../base/ILOPoolImmutableState.sol';

contract ILOPoolImmutableStateTest is ILOPoolImmutableState {
    constructor(address _factory, address _WETH9) ILOPoolImmutableState(_factory, _WETH9) {}
}
