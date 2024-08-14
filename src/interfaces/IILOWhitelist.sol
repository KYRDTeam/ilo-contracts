// SPDX-License-Identifier: BUSL-1.1

pragma solidity =0.7.6;

interface IILOWhitelist {
    event SetWhitelist(address indexed user, uint256 allocation);
    event SetPublicAllocation(uint256 allocation);

    function setPublicAllocation(uint256 _allocation) external;
    function setWhiteList(
        address[] calldata users,
        uint256[] calldata allocations
    ) external;
    function allocation(address user) external view returns (uint256);
    function whitelistedCount() external view returns (uint256);

    modifier onlyProjectAdmin() virtual;
}
