# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

.PHONY: test

register-mainnet :; forge script RegisterNodes \
				-s "run()" \
				--rpc-url ${POLYGON_MAINNET_RPC_URL} \
				--chain-id 137 \
				--legacy \
				--slow \
				-i 1 \
				--broadcast \
				--ffi \
				-vvvvv \
				--delay 30

register-mumbai :; forge script RegisterNodes \
				-s "run()" \
				--rpc-url ${POLYGON_MUMBAI_RPC_URL} \
				--chain-id 80001 \
				--legacy \
				--slow \
				-i 1 \
				--broadcast \
				--ffi \
				-vvvvv

register-local :; forge script RegisterNodes \
				-s "run()" \
				--rpc-url ${LOCAL_RPC_URL} \
				-i 1 \
				--broadcast \
				--ffi \
				-vvvvv
