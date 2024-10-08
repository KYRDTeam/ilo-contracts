ifneq (,$(wildcard ./.env))
    include .env
    export
endif

DEPLOY_CMD = forge script script/Deploy.s.sol:$(CONTRACT)Script --rpc-url $(RPC_URL) --broadcast

.PHONY: clean test
all: clean deploy-all-contracts verify-all-contracts
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
deploy-all-contracts:
deploy-ilo-manager:
deploy-ilo-pool:
deploy-ilo-pool-sale:
deploy-token-factory:

deploy-all-contracts-legacy:
deploy-ilo-manager-legacy:
deploy-ilo-pool-legacy:
deploy-ilo-pool-sale-legacy:
deploy-token-factory-legacy:

deploy-all-contracts-with-gas-price:
deploy-ilo-manager-with-gas-price:
deploy-ilo-pool-with-gas-price:
deploy-ilo-pool-sale-with-gas-price:
deploy-token-factory-with-gas-price:

deploy-%: % 
	$(DEPLOY_CMD)
deploy-%-legacy: % 
	$(DEPLOY_CMD) --legacy
deploy-%-with-gas-price: %
	$(DEPLOY_CMD) --legacy --gas-price $(GAS_PRICE)

verify-all-contracts:
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
