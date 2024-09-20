// SPDX-License-Identifier: MIT

pragma solidity =0.7.6;

interface IERC20Whitelist {
    event WhitelistContractRemoved();

    function removeWhitelistContract() external;
    function whitelistContract() external view returns (address);
}
