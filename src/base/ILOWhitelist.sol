// SPDX-License-Identifier: BUSL-1.1

pragma solidity =0.7.6;

import { IILOWhitelist } from '../interfaces/IILOWhitelist.sol';

abstract contract ILOWhitelist is IILOWhitelist {
    uint256 private _whitelistCount;
    uint256 public PUBLIC_ALLOCATION;
    mapping(address => uint256) private _userAllocation;

    /// @inheritdoc IILOWhitelist
    function setPublicAllocation(
        uint256 _allocation
    ) external override onlyProjectAdmin {
        PUBLIC_ALLOCATION = _allocation;
        emit SetPublicAllocation(_allocation);
    }

    /// @inheritdoc IILOWhitelist
    function setWhiteList(
        address[] calldata users,
        uint256[] calldata allocations
    ) external override onlyProjectAdmin {
        require(
            users.length == allocations.length,
            'ILOWhitelist: INVALID_LENGTH'
        );
        for (uint256 i = 0; i < users.length; i++) {
            if (allocations[i] == 0) {
                _removeWhitelist(users[i]);
            } else {
                _setWhitelist(users[i], allocations[i]);
            }
        }
    }

    /// @inheritdoc IILOWhitelist
    function whitelistedCount() external view override returns (uint256) {
        return _whitelistCount;
    }

    /// @inheritdoc IILOWhitelist
    function allocation(address user) public view override returns (uint256) {
        return
            _userAllocation[user] > PUBLIC_ALLOCATION
                ? _userAllocation[user]
                : PUBLIC_ALLOCATION;
    }

    function _setWhitelist(address user, uint256 _allocation) internal {
        if (_userAllocation[user] == 0) {
            _whitelistCount++;
        }
        _userAllocation[user] = _allocation;
        emit SetWhitelist(user, _allocation);
    }

    function _removeWhitelist(address user) internal {
        if (_userAllocation[user] != 0) {
            _whitelistCount--;
            delete _userAllocation[user];
            emit SetWhitelist(user, 0);
        }
    }
}
