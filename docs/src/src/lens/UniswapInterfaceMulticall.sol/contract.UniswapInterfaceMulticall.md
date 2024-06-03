# UniswapInterfaceMulticall
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/da7613c22bad547ebd26a45d76010fc3957237e9/src/lens/UniswapInterfaceMulticall.sol)

A fork of Multicall2 specifically tailored for the Uniswap Interface


## Functions
### getCurrentBlockTimestamp


```solidity
function getCurrentBlockTimestamp() public view returns (uint256 timestamp);
```

### getEthBalance


```solidity
function getEthBalance(address addr) public view returns (uint256 balance);
```

### multicall


```solidity
function multicall(Call[] memory calls) public returns (uint256 blockNumber, Result[] memory returnData);
```

## Structs
### Call

```solidity
struct Call {
    address target;
    uint256 gasLimit;
    bytes callData;
}
```

### Result

```solidity
struct Result {
    bool success;
    uint256 gasUsed;
    bytes returnData;
}
```

