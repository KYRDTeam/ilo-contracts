# Overview:
https://docs.liquidpad.io/

# Deployment Address

NOTE: Token factory on arbitrum and ethereum is an old version containing a bug that lead to unable to create whitelist contracts. ONLY base has updated address with the fix

| | Arbitrum | Base | Ethereum |
|--- |--- |--- |--- |
| ILOManager | [0x10e6662269C3A6255E59c3E55c2f5624c7B983c5](https://arbiscan.io/address/0x10e6662269C3A6255E59c3E55c2f5624c7B983c5) | [0x10e6662269C3A6255E59c3E55c2f5624c7B983c5](https://basescan.org/address/0x10e6662269C3A6255E59c3E55c2f5624c7B983c5) | [0x10e6662269C3A6255E59c3E55c2f5624c7B983c5](https://etherscan.io/address/0x10e6662269C3A6255E59c3E55c2f5624c7B983c5) |
| ILOPool Implementation | - | [0x1516fb2f49e6a47dd4721c64e4403b436296f421](https://basescan.org/address/0x1516fb2f49e6a47dd4721c64e4403b436296f421) | - |
| ILOPool Sale Implementation | [0x7cd0F25A2d133F5e869ccF6a8A2dda693BecF15A](https://arbiscan.io/address/0x7cd0F25A2d133F5e869ccF6a8A2dda693BecF15A) | [0x7cd0F25A2d133F5e869ccF6a8A2dda693BecF15A](https://basescan.org/address/0x7cd0F25A2d133F5e869ccF6a8A2dda693BecF15A) | [0x7cd0F25A2d133F5e869ccF6a8A2dda693BecF15A](https://etherscan.io/address/0x7cd0F25A2d133F5e869ccF6a8A2dda693BecF15A) |
| Token Factory | - | [0xB60D14B63b3240E306a127695851ca3f409dC578](https://basescan.org/address/0xB60D14B63b3240E306a127695851ca3f409dC578) | - |
| ILOManager(Dev env) | - | [0x53D7AfC47A7DdA30605EA3907201f19f851a660D](https://basescan.org/address/0x53D7AfC47A7DdA30605EA3907201f19f851a660D) | - |
| Token Factory(Dev env) | - | [0x3A84fD3c3d10F8F447656E27000cF82230333260](https://basescan.org/address/0x3A84fD3c3d10F8F447656E27000cF82230333260) | - |

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
