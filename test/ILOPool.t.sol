// SPDX-License-Identifier: MIT

pragma solidity =0.7.6;
pragma abicoder v2;

import { IntegrationTestBase, Mock } from './IntegrationTestBase.sol';
import { ILOPool } from '../src/ILOPool.sol';

contract ILOPoolTest is IntegrationTestBase {
    function setUp() external {
        _setupBase();
    }

    function testName() external {
        ILOPool iloPool = new ILOPool();
        string memory expectedName = 'KRYSTAL ILOPool V3';
        string memory actualName = iloPool.name();
        assertEq(actualName, expectedName);
    }

    function testSymbol() external {
        ILOPool iloPool = new ILOPool();
        string memory expectedSymbol = 'KRYSTAL-ILO-V3';
        string memory actualSymbol = iloPool.symbol();
        assertEq(actualSymbol, expectedSymbol);
    }
}
