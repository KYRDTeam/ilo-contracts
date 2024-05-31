# Overview:
https://docs.liquidpad.io/

# Detail contract docs([See here](docs/src/SUMMARY.md)):

# Contract Integration

## For project owner:

[Init project](docs/src/src/ILOManager.sol/contract.ILOManager.md#initProject):
```solidity
struct LinearVest {
    uint16 percentage; // vesting percentage in total liquidity (in BPS)
    uint64 start;
    uint64 end;
}

struct ProjectVestConfig {
    uint16 shares; // BPS shares
    string name;
    address recipient;
    LinearVest[] vestSchedule;
}

function initProject(
    address saleToken,
    address raiseToken,
    uint24 fee,
    uint160 initialPoolPriceX96,
    uint64 launchTime,
    uint16 investorShares,
    ProjectVestConfig[] calldata projectVestConfigs
) external override returns (address uniV3PoolAddress);
```

[Init ILO Pool](docs/src/src/ILOManager.sol/contract.ILOManager.md#initILOPool):
```solidity
struct LinearVest {
    uint16 percentage; // vesting percentage in total liquidity (in BPS)
    uint64 start;
    uint64 end;
}

struct InitPoolParams {
    address uniV3Pool;
    int24 tickLower; int24 tickUpper;
    uint256 hardCap; // total amount of raise tokens
    uint256 softCap; // minimum amount of raise token needed for launch pool
    uint256 maxCapPerUser; // TODO: user tiers
    uint64 start;
    uint64 end;
    LinearVest[] investorVestConfigs;
}

function initILOPool(InitPoolParams calldata params) external override onlyProjectAdmin(params.uniV3Pool) returns (address iloPoolAddress);
```

## For investors:
[Buy ILO](docs/src/src/ILOPool.sol/contract.ILOPool.md#buy)
```solidity
function buy(uint256 raiseAmount, address recipient)
    external override 
    duringSale()
    onlyWhitelisted(params.recipient)
    returns (
        uint256 tokenId,
        uint128 liquidityDelta,
        uint256 amountAdded0,
        uint256 amountAdded1
    );
```

[Claim vesting ILO](docs/src/src/ILOPool.sol/contract.ILOPool.md#claim)
```solidity
function claim(uint256 tokenId) external payable returns (uint256 amount0, uint256 amount1);
```

## For everybody:
[Launch All Liquidity](docs/src/src/ILOManager.sol/contract.ILOManager.md#launch):
```solidity
function launch(address uniV3PoolAddress);
```

