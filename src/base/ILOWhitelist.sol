// SPDX-License-Identifier: MIT 

pragma solidity =0.7.6;

import '@openzeppelin/contracts/utils/EnumerableSet.sol';

abstract contract ILOWhitelist {
    event SetWhitelist(address indexed user, bool isWhitelist);

    modifier onlyWhitelisted(address user) {
        require(_whitelisted.contains(user));
        _;
    }

    EnumerableSet.AddressSet private _whitelisted;
    
    /// @notice check if the address is whitelisted
    function isWhitelisted(address user) external view returns (bool) {
        return _whitelisted.contains(user);
    }

    function setWhitelist(address user) external {
        _setWhitelist(user);
    }

    function _removeWhitelist(address user) internal {
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
        _whitelisted.remove(user);
        emit SetWhitelist(user, false);
    }

    function _setWhitelist(address user) internal {
        _whitelisted.set(user);
        emit SetWhitelist(user, true);
    }
}
