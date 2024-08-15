// SPDX-License-Identifier: MIT

pragma solidity =0.7.6;

interface IERC20Whitelist {
    function setWhitelistContract(address _whitelistContract) external;
    function whitelistContract() external view returns (address);
}
