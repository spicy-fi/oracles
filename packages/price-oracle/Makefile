# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

.PHONY: test

# defaults
newProxy=false
seed=false

# deployment
deploy-mainnet :; @forge script Deploy \
				-s "run(bool, bool)" ${newProxy} ${seed} \
				--rpc-url ${POLYGON_MAINNET_RPC_URL} \
				--chain-id 137 \
				--legacy \
				-i 1 \
				--broadcast \
				--ffi \
				-vvvvv \
				--delay 30

deploy-mumbai :; forge script Deploy \
				-s "run(bool, bool)" ${newProxy} ${seed} \
				--rpc-url ${POLYGON_MUMBAI_RPC_URL} \
				--chain-id 80001 \
				--legacy \
				-i 1 \
				--broadcast \
				--ffi \
				-vvvvv

deploy-local :; forge script Deploy \
				-s "run(bool, bool)" ${newProxy} ${seed} \
				--rpc-url ${LOCAL_RPC_URL} \
				--legacy \
				-i 1 \
				--broadcast \
				--ffi \
				-vvvvv
