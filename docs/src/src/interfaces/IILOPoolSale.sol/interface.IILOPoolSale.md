# IILOPoolSale
[Git Source](https://github.com/KYRDTeam/ilo-contracts/blob/e40a6cd6fab3cc84638afa793f4d9e791b183158/src/interfaces/IILOPoolSale.sol)

**Inherits:**
[IILOPoolBase](/src/interfaces/IILOPoolBase.sol/interface.IILOPoolBase.md), [IILOWhitelist](/src/interfaces/IILOWhitelist.sol/interface.IILOWhitelist.md)


## Functions
### initialize


```solidity
function initialize(InitParams calldata params) external;
```

### buy

this function is for investor buying ILO


```solidity
function buy(uint256 raiseAmount, address recipient) external returns (uint256 tokenId);
```

### claimRefund


```solidity
function claimRefund(uint256 tokenId) external returns (uint256 refundAmount);
```

### SALE_START


```solidity
function SALE_START() external view returns (uint64);
```

### SALE_END


```solidity
function SALE_END() external view returns (uint64);
```

### MIN_RAISE


```solidity
function MIN_RAISE() external view returns (uint256);
```

### MAX_RAISE


```solidity
function MAX_RAISE() external view returns (uint256);
```

### TOTAL_RAISED


```solidity
function TOTAL_RAISED() external view returns (uint256);
```

### tokenSoldAmount


```solidity
function tokenSoldAmount() external view returns (uint256);
```

## Events
### ILOPoolSaleInitialized

```solidity
event ILOPoolSaleInitialized(InitPoolBaseParams baseParams, SaleParams saleParams, LinearVest[] vestingSchedule);
```

### PoolSaleCancelled

```solidity
event PoolSaleCancelled();
```

### PoolSaleLaunched

```solidity
event PoolSaleLaunched(uint256 totalRaised, uint128 liquidity);
```

## Structs
### SaleParams

```solidity
struct SaleParams {
    uint64 start;
    uint64 end;
    uint256 minRaise;
    uint256 maxRaise;
}
```

### InitParams

```solidity
struct InitParams {
    InitPoolBaseParams baseParams;
    SaleParams saleParams;
    LinearVest[] vestingSchedule;
}
```

