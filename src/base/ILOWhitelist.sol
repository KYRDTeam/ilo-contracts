// SPDX-License-Identifier: BUSL-1.1 

pragma solidity =0.7.6;

import '@openzeppelin/contracts/utils/EnumerableSet.sol';

abstract contract ILOWhitelist {
    event SetWhitelist(address indexed user, bool isWhitelist);
    event SetOpenToAll(bool openToAll);

    bool private _openToAll;

    modifier onlyWhitelisted(address user) {
        require(_openToAll || EnumerableSet.contains(_whitelisted, user));
        _;
    }

    EnumerableSet.AddressSet private _whitelisted;
    
    function setOpenToAll(bool openToAll) external {
        _openToAll = openToAll;
        emit SetOpenToAll(openToAll);
    }

    function isOpenToAll() external view returns(bool) {
        return _openToAll;
    }

    /// @notice check if the address is whitelisted
    function isWhitelisted(address user) external view returns (bool) {
        return EnumerableSet.contains(_whitelisted, user);
    }

    function setWhitelist(address user) external {
        _setWhitelist(user);
    }

    function removeWhitelist(address user) external {
        _removeWhitelist(user);
    }

    function batchWhitelist(address[] calldata users) external {
        for (uint256 i = 0; i < users.length; i++) {
            _setWhitelist(users[i]);
        }
    }

    function batchRemoveWhitelist(address[] calldata users) external {
        for (uint256 i = 0; i < users.length; i++) {
            _removeWhitelist(users[i]);
        }
    }

    function _removeWhitelist(address user) internal {
        EnumerableSet.remove(_whitelisted, user);
        emit SetWhitelist(user, false);
    }

    function _setWhitelist(address user) internal {
        EnumerableSet.add(_whitelisted, user);
        emit SetWhitelist(user, true);
    }
}
