// SPDX-License-Identifier: MIT 

pragma solidity =0.7.6;
pragma abicoder v2;

import "./IntegrationTestBase.sol";

contract ILOPoolTest is IntegrationTestBase {
    function setUp() external {
        _setupBase();
        _initPool(PROJECT_OWNER, _getInitPoolParams());
    }
}