ifneq (,$(wildcard ./.env))
    include .env
    export
endif
.PHONY: clean
clean:
	forge clean && rm -rf cache
ilo-manager:
	$(eval CONTRACT=ILOManager)
ilo-pool:
	$(eval CONTRACT=ILOPool)
deploy-ilo-manager:
deploy-ilo-pool:
deploy-%: %
	forge script script/$(CONTRACT).s.sol:$(CONTRACT)Script --rpc-url $(RPC_URL) --broadcast
verify-ilo-manager:
verify-ilo-pool:
verify-%: %
	forge script script/Verify.s.sol:Verify$(CONTRACT)Script | awk 'END{print}' | bash
init-ilo-manager:
init-ilo-pool:
init-%: %
	forge script script/Init.s.sol:$(CONTRACT)InitializeScript --rpc-url $(RPC_URL) --broadcast
