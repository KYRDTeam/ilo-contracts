# Overview:
https://docs.liquidpad.io/

# Build and deploy:

TL;DR: `make all`. this command require all env below. (see `sample.env` file)

env can store in `.env` file or export before run command.

## Build:
```bash
    forge build
```
## Test:
```bash
    make test
```

## Deploy:

TL;DR: `make deploy-all-contract` . This command require all env below

All deploy script require `SALT_SEED`, `PRIVATE_KEY`, `RPC_URL`, `CHAIN_ID` env

- Deploy ilo-manager: 
```bash
make deploy-ilo-manager
```

Initialize ilo-manager:
require env: `FEE_TAKER`, `OWNER`, `PLATFORM_FEE`, `PERFORMANCE_FEE`, `UNIV3_FACTORY`, `WETH9`
```bash
make init-ilo-manager
```

- Deploy ilo-pool: 
```bash
make deploy-ilo-pool
```

## Verify contract:

TL;DR: `make verify-all-contract` . This command require all env below

All verify script require `SALT_SEED`, `ETHERSCAN_API_KEY`, `VERIFIER_URL`, `CHAIN_ID` env.

- Verify ilo-manager contract:
```bash
make verify-ilo-manager
```
- Verify ilo-pool contract:
```bash
make verify-ilo-pool
```



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

struct InitProjectParams {
    // the sale token
    address saleToken;
    // the raise token
    address raiseToken;
    // uniswap v3 fee tier
    uint24 fee;
    // uniswap sqrtPriceX96 for initialize pool
    uint160 initialPoolPriceX96;
    // time for lauch all liquidity. Only one launch time for all ilo pools
    uint64 launchTime;
    // number of liquidity shares after investor invest into ilo pool interm of BPS = 10000
    uint16 investorShares;  // BPS shares
    // config for all other shares and vest
    ProjectVestConfig[] projectVestConfigs;
}

/// @notice init project with details
/// @param params the parameters to initialize the project
/// @return uniV3PoolAddress address of uniswap v3 pool. We use this address as project id
function initProject(InitProjectParams calldata params) external returns(address uniV3PoolAddress);
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

# ERROR:
|  Code	|   Description	           |
|---	|---	                   |
|   UA	| Unauthorized             |
|   NI	| Not initialized          |
|   RE	| Re-initialize            |
|   PT	| Invalid Pool Time        |
|   VT	| Invalid Vest Time        |
|   LT	| Invalid Launch Time      |
|   SLT	| Invalid Sale Time        |
|  RFT	| Invalid Refund Time      |
|   TS	| Invalid Total Shares     |
|   VS	| Invalid Vest Shares      |
|   NP	| No Pools                 |
|  UV3P	| Invalid Uni V3 Pool      |
|   HC	| Over Hard Cap            |
|   UC	| Over User Cap            |
|   SC	| Soft cap not met         |
|   SA	| Over Sale Amount         |
|   ZA	| Zero Buy Amount          |
|  PNL	| Pool Not Launched        |
|   PL	| Pool Launched            |
|  IRF	| Pool In Refund state     |
|  VR	| Invalid Vesting recipient|

# Deployment Address

## ILOManager

### Production: 0x0d781106DA1da95f76150e16D1c6fCCf1e41B762
- [arbitrum](https://arbiscan.io/address/0x0d781106DA1da95f76150e16D1c6fCCf1e41B762)
- [base](https://basescan.org/address/0x0d781106DA1da95f76150e16D1c6fCCf1e41B762)
- [ethereum](https://etherscan.io/address/0x0d781106DA1da95f76150e16D1c6fCCf1e41B762)

### Dev: 0x11754143Ab82385fafc669d041D80f52F503064d
- [arbitrum](https://arbiscan.io/address/0x11754143Ab82385fafc669d041D80f52F503064d)
- [base](https://basescan.org/address/0x11754143Ab82385fafc669d041D80f52F503064d)

## ILOPool Implementation:
- [arbitrum](https://arbiscan.io/address/0x103F1E72e38B11304d47BEA96eA673d63E0C7261)
- [base](https://basescan.org/address/0x103F1E72e38B11304d47BEA96eA673d63E0C7261)
- [ethereum](https://etherscan.io/address/0x103F1E72e38B11304d47BEA96eA673d63E0C7261)

## Token Factory
- [arbitrum](https://arbiscan.io/address/0x7bBe253CC047CE08D19c2aFEfbE48E121c9e65c5)
- [base](https://basescan.org/address/0x7bBe253CC047CE08D19c2aFEfbE48E121c9e65c5)
