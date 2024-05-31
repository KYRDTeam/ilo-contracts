// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Immutable state
/// @notice Functions that return immutable state of the router
interface IILOPoolImmutableState {
    /// @return Returns the address of WETH9
    function WETH9() external view returns (address);
}
