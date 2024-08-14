// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;
import './IILOManager.sol';

/// @title Immutable state
/// @notice Functions that return immutable state of the router
interface IILOPoolImmutableState {
    function MANAGER() external view returns (IILOManager);
    function PAIR_TOKEN() external view returns (address);
    function TICK_LOWER() external view returns (int24);
    function TICK_UPPER() external view returns (int24);
    function PROJECT_ID() external view returns (string memory);
    function IMPLEMENTATION() external view returns (address);
    function PROJECT_NONCE() external view returns (uint256);
}
