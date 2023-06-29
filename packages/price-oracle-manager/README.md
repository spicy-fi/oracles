# SpicyFi Price Oracle Manager

This package takes care of registering the oracle nodes on the blockchain. It targets the Oracle Managers that were deployed by Cannon from Synthetix. We use their original script to deploy the Oracle Manager since they have a exlusive router plugin for Cannon that we could not transpile to Solidity. This script can be found in `spicy-fi/synthetix-v3` with some modification.

Ideally, we should have the source code as well as the deployment script in this repo for the Oracle Managers.

## Dependencies

- The `spicy-fi/synthetix-v3` repo is used as one of the dependencies.

## Usage

1. Install the dependencies with pnpm `pnpm install
2. Create the env file from the example file provided: `cp .env.example .env`
3. The values provided in the example file should be the current valid addresses. Fill the missing values.
4. Make sure that the JSON files containing the addresses of the oracles are correct `script/input/{CHAINID}/nodes.json`
5. Run `pnpm registerNodes:mumbai` or `pnpm registerNodes:mainnet` for deployment, which will register the nodes from the json file.
6. The script might fail as Foundry is only capable of sending 100 txs per run as of now. Execute the script again, it will resume.
7. You can also run the same command for updating the oracle addresses. It registers the new oracle nodes only (skipping the ones registered before).
