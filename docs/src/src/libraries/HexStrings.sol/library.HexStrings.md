# HexStrings
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/1de4d92cce6f0722e8736db455733703c706f30f/src/libraries/HexStrings.sol)


## State Variables
### ALPHABET

```solidity
bytes16 internal constant ALPHABET = "0123456789abcdef";
```


## Functions
### toHexString

Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.

*Credit to Open Zeppelin under MIT license https://github.com/OpenZeppelin/openzeppelin-contracts/blob/243adff49ce1700e0ecb99fe522fb16cff1d1ddc/contracts/utils/Strings.sol#L55*


```solidity
function toHexString(uint256 value, uint256 length) internal pure returns (string memory);
```

### toHexStringNoPrefix


```solidity
function toHexStringNoPrefix(uint256 value, uint256 length) internal pure returns (string memory);
```

