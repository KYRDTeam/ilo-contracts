ifneq (,$(wildcard ./.env))
    include .env
    export
endif

DEPLOY_CMD = forge script script/Deploy.s.sol:$(CONTRACT)Script --rpc-url $(RPC_URL) --broadcast

.PHONY: clean test
all: clean deploy-all-contract verify-all-contract
test:
	forge test --gas-report
clean:
	forge clean && rm -rf cache
ilo-manager:
	$(eval CONTRACT=ILOManager)
ilo-pool:
	$(eval CONTRACT=ILOPool)
ilo-pool-sale:
	$(eval CONTRACT=ILOPoolSale)
token-factory:
	$(eval CONTRACT=TokenFactory)
all-contracts:
	$(eval CONTRACT=AllContracts)
deploy-all-contract:
deploy-ilo-manager:
deploy-ilo-pool:
deploy-ilo-pool-sale:
deploy-token-factory:
deploy-token-factory-legacy:
deploy-ilo-manager-legacy:
deploy-ilo-pool-legacy:
deploy-ilo-manager-with-gas-price:
deploy-ilo-pool-with-gas-price:
deploy-%: % 
	$(DEPLOY_CMD)
deploy-%-legacy: % 
	$(DEPLOY_CMD) --legacy
deploy-%-with-gas-price: %
	$(DEPLOY_CMD) --legacy --gas-price $(GAS_PRICE)

verify-ilo-manager:
verify-token-factory:
verify-ilo-pool:
verify-ilo-pool-sale:
verify-%: %
	forge script script/Verify.s.sol:Verify$(CONTRACT)Script | awk 'END{print}' | bash
init-ilo-manager:
init-token-factory:
init-%: %
	forge script script/Init.s.sol:$(CONTRACT)InitializeScript --rpc-url $(RPC_URL) --broadcast
