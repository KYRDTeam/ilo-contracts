// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

import { Create2 } from '@openzeppelin/contracts/utils/Create2.sol';
import { Script } from 'forge-std/Script.sol';
import { ILOPool } from '../src/ILOPool.sol';
import { ILOPoolSale } from '../src/ILOPoolSale.sol';
import { ILOManager } from '../src/ILOManager.sol';
import { TokenFactory } from '../src/TokenFactory.sol';

abstract contract CommonScript is Script {
    bytes16 private constant HEX_DIGITS = '0123456789abcdef';

    bytes32 salt;
    address factory = 0x4e59b44847b379578588920cA78FbF26c0B4956C;

    function toHexString(
        uint256 value,
        uint256 length
    ) internal pure returns (string memory) {
        uint256 localValue = value;
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = '0';
        buffer[1] = 'x';
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = HEX_DIGITS[localValue & 0xf];
            localValue >>= 4;
        }
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal
     * representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), 20);
    }

    function getILOManagerDeploymentAddress() internal view returns (address) {
        return
            Create2.computeAddress(
                salt,
                keccak256(abi.encodePacked(type(ILOManager).creationCode)),
                factory
            );
    }

    function getILOPoolDeploymentAddress() internal view returns (address) {
        return
            Create2.computeAddress(
                salt,
                keccak256(abi.encodePacked(type(ILOPool).creationCode)),
                factory
            );
    }

    function getILOPoolSaleDeploymentAddress() internal view returns (address) {
        return
            Create2.computeAddress(
                salt,
                keccak256(abi.encodePacked(type(ILOPoolSale).creationCode)),
                factory
            );
    }

    function getTokenFactoryDeploymentAddress()
        internal
        view
        returns (address)
    {
        return
            Create2.computeAddress(
                salt,
                keccak256(abi.encodePacked(type(TokenFactory).creationCode)),
                factory
            );
    }

    constructor() {
        salt = keccak256(bytes(vm.envString('SALT_SEED')));
    }
}
