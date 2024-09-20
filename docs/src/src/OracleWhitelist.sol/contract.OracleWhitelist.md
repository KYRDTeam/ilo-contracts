# OracleWhitelist
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/af88dd9b3e8283ab97b6c9511aeb7bb607e3649d/src/OracleWhitelist.sol)

**Inherits:**
[IOracleWhitelist](/src/interfaces/IOracleWhitelist.sol/interface.IOracleWhitelist.md), [UniswapV3Oracle](/src/base/UniswapV3Oracle.sol/abstract.UniswapV3Oracle.md), Ownable

The main functionalities are:
- Ownable: Add whitelisted addresses
- Ownable: Set max quote token amount to buy(default 3 quote token)
- Ownable: Set univ3 TWAP oracle
- Token contract `_beforeTokenTransfer` hook will call `checkWhitelist` function and this function will check if buyer is eligible


## State Variables
### _maxAddressCap
*Maximum quote token amount to contribute*


```solidity
uint256 private _maxAddressCap;
```


### _locked
*Flag for locked period*


```solidity
bool private _locked;
```


### _whitelistedAddresses

```solidity
EnumerableSet.AddressSet private _whitelistedAddresses;
```


### _contributed
*Whitelist index for each whitelisted address*


```solidity
mapping(address => uint256) private _contributed;
```


## Functions
### onlyToken

Check if called from token contract.


```solidity
modifier onlyToken();
```

### constructor


```solidity
constructor(address owner, address _pool, address _quoteToken, bool _lockBuy, uint256 _maxCap);
```

### checkWhitelist

Check if address to is eligible for whitelist

*Check WL should be applied only*

*Revert if locked, not whitelisted or already contributed more than capped amount*

*Update contributed amount*


```solidity
function checkWhitelist(address from, address to, uint256 amount) external override onlyToken;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|sender address|
|`to`|`address`|recipient address|
|`amount`|`uint256`|Number of tokens to be transferred|


### setLocked

Setter for locked flag


```solidity
function setLocked(bool newLocked) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newLocked`|`bool`|New flag to be set|


### setMaxAddressCap

Setter for max address cap


```solidity
function setMaxAddressCap(uint256 newCap) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newCap`|`uint256`|New cap for max ETH amount|


### setToken

Setter for token


```solidity
function setToken(address newToken) external override onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newToken`|`address`|New token address|


### setPool

Setter for Univ3 pool


```solidity
function setPool(address newPool) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newPool`|`address`|New pool address|


### addBatchWhitelist

Add batch whitelists


```solidity
function addBatchWhitelist(address[] calldata whitelisted) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`whitelisted`|`address[]`|Array of addresses to be added|


### removeBatchWhitelist

Remove batch whitelists


```solidity
function removeBatchWhitelist(address[] calldata whitelisted) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`whitelisted`|`address[]`|Array of addresses to be removed|


### maxAddressCap

Returns max address cap


```solidity
function maxAddressCap() external view returns (uint256);
```

### contributed

Returns contributed ETH amount for address


```solidity
function contributed(address to) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|The address to be checked|


### locked

If token transfer is locked or not


```solidity
function locked() external view returns (bool);
```

### whitelistCount

whitelist count


```solidity
function whitelistCount() external view returns (uint256);
```

### isWhitelisted

check if address is whitelisted


```solidity
function isWhitelisted(address whitelisted) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`whitelisted`|`address`|Address to be checked|


