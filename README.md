# Overview:
https://docs.liquidpad.io/

# Deployment Address

| | Arbitrum | Base | Ethereum |
|--- |--- |--- |--- |
| ILOManager | [0x72839Bd277787E1273A447d7042e40beC33F48f2](https://arbiscan.io/address/0x72839Bd277787E1273A447d7042e40beC33F48f2) | [0x72839Bd277787E1273A447d7042e40beC33F48f2](https://basescan.org/address/0x72839Bd277787E1273A447d7042e40beC33F48f2) | [0x72839Bd277787E1273A447d7042e40beC33F48f2](https://etherscan.io/address/0x72839Bd277787E1273A447d7042e40beC33F48f2) |
| ILOPool Implementation | [0xc493aD3604a3b4345413F01c3852D116892ee8B3](https://arbiscan.io/address/0xc493aD3604a3b4345413F01c3852D116892ee8B3) | [0xc493aD3604a3b4345413F01c3852D116892ee8B3](https://basescan.org/address/0xc493aD3604a3b4345413F01c3852D116892ee8B3) | [0xc493aD3604a3b4345413F01c3852D116892ee8B3](https://etherscan.io/address/0xc493aD3604a3b4345413F01c3852D116892ee8B3) |
| ILOPool Sale Implementation | [0x72839Bd277787E1273A447d7042e40beC33F48f2](https://arbiscan.io/address/0x72839Bd277787E1273A447d7042e40beC33F48f2) | [0x72839Bd277787E1273A447d7042e40beC33F48f2](https://basescan.org/address/0x72839Bd277787E1273A447d7042e40beC33F48f2) | [0x72839Bd277787E1273A447d7042e40beC33F48f2](https://etherscan.io/address/0x72839Bd277787E1273A447d7042e40beC33F48f2) |
| Token Factory | [0x580D693ec4d0131b200CD112D0706D1149a16EA0](https://arbiscan.io/address/0x580D693ec4d0131b200CD112D0706D1149a16EA0) | [0x580D693ec4d0131b200CD112D0706D1149a16EA0](https://basescan.org/address/0x580D693ec4d0131b200CD112D0706D1149a16EA0) | [0x580D693ec4d0131b200CD112D0706D1149a16EA0](https://etherscan.io/address/0x580D693ec4d0131b200CD112D0706D1149a16EA0) |
| ILOManager(Dev env) | - | [0x4E89E144ac87a51796c03C79FB1B2acFA25117c6](https://basescan.org/address/0x4E89E144ac87a51796c03C79FB1B2acFA25117c6) | - |

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
