# IERC1271
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/af88dd9b3e8283ab97b6c9511aeb7bb607e3649d/src/interfaces/external/IERC1271.sol)

Interface that verifies provided signature for the data

*Interface defined by EIP-1271*


## Functions
### isValidSignature

Returns whether the provided signature is valid for the provided data

*MUST return the bytes4 magic value 0x1626ba7e when function passes.
MUST NOT modify state (using STATICCALL for solc < 0.5, view modifier for solc > 0.5).
MUST allow external calls.*


```solidity
function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`hash`|`bytes32`|Hash of the data to be signed|
|`signature`|`bytes`|Signature byte array associated with _data|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`magicValue`|`bytes4`|The bytes4 magic value 0x1626ba7e|


