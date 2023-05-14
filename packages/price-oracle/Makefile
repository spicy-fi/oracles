# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

.PHONY: test

# defaults
newProxy=false

# deployment
deploy-mainnet :; @forge script Deploy \
				-s "run(bool)" ${newProxy} \
				--rpc-url ${INFURA_POLYGON_MAINNET_RPC_URL}${INFURA_POLYGON_MAINNET_API_KEY} \
				--chain-id 137 \
				-i 1 \
				--broadcast \
				--ffi \
				-vvvvv \
				--delay 30

deploy-mumbai :; forge script Deploy \
				-s "run(bool)" ${newProxy} \
				--rpc-url ${INFURA_POLYGON_MUMBAI_RPC_URL}${INFURA_POLYGON_MUMBAI_API_KEY} \
				--chain-id 80001 \
				-i 1 \
				--broadcast \
				--ffi \
				-vvvvv

deploy-local :; forge script DeploySpicyOracle \
				-s "run(bool)" ${newProxy} \
				--rpc-url ${LOCAL_RPC_URL} \
				-i 1 \
				--broadcast \
				--ffi \
				-vvvvv
