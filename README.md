# Overview:
https://docs.liquidpad.io/

# Deployment Address

| | Arbitrum | Base | Ethereum |
|--- |--- |--- |--- |
| ILOManager | [0xAD49faC6eda433E7cF94E416CDB67564aA9d0D0c](https://arbiscan.io/address/0xAD49faC6eda433E7cF94E416CDB67564aA9d0D0c) | [0xAD49faC6eda433E7cF94E416CDB67564aA9d0D0c](https://basescan.org/address/0xAD49faC6eda433E7cF94E416CDB67564aA9d0D0c) | [0xAD49faC6eda433E7cF94E416CDB67564aA9d0D0c](https://etherscan.io/address/0xAD49faC6eda433E7cF94E416CDB67564aA9d0D0c) |
| ILOPool Implementation | [0xa4d2EB0C75304Ae7E947e8c0034053bbC2CF8672](https://arbiscan.io/address/0xa4d2EB0C75304Ae7E947e8c0034053bbC2CF8672) | [0xa4d2EB0C75304Ae7E947e8c0034053bbC2CF8672](https://basescan.org/address/0xa4d2EB0C75304Ae7E947e8c0034053bbC2CF8672) | [0xa4d2EB0C75304Ae7E947e8c0034053bbC2CF8672](https://etherscan.io/address/0xa4d2EB0C75304Ae7E947e8c0034053bbC2CF8672) |
| ILOPool Sale Implementation | [0x6002F368969b9c020c7c428235403F0eE1b8fb93](https://arbiscan.io/address/0x6002F368969b9c020c7c428235403F0eE1b8fb93) | [0x6002F368969b9c020c7c428235403F0eE1b8fb93](https://basescan.org/address/0x6002F368969b9c020c7c428235403F0eE1b8fb93) | [0x6002F368969b9c020c7c428235403F0eE1b8fb93](https://etherscan.io/address/0x6002F368969b9c020c7c428235403F0eE1b8fb93) |
| Token Factory | [0x90fFAA19080331808eCADE56bAB0C62EE9ffd2EB](https://arbiscan.io/address/0x90fFAA19080331808eCADE56bAB0C62EE9ffd2EB) | [0x90fFAA19080331808eCADE56bAB0C62EE9ffd2EB](https://basescan.org/address/0x90fFAA19080331808eCADE56bAB0C62EE9ffd2EB) | [0x90fFAA19080331808eCADE56bAB0C62EE9ffd2EB](https://etherscan.io/address/0x90fFAA19080331808eCADE56bAB0C62EE9ffd2EB) |
| ILOManager(Dev env) | - | [0x1ad05dc427D4fcBfa8652637d06c7C74467Ac294](https://basescan.org/address/0x1ad05dc427D4fcBfa8652637d06c7C74467Ac294) | - |

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
