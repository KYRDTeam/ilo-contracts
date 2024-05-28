// SPDX-License-Identifier: MIT 

pragma solidity =0.7.6;

abstract contract Initializable {
    bool private _initialized;
    modifier whenNotInitialized() {
        require(!_initialized);
        _;
        _initialized = true;
    }
}