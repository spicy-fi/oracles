// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// solhint-disable-next-line no-global-import
import "forge-std/Script.sol";

abstract contract ScriptPlus is Script {
    address internal _owner;

    constructor() {
        if (block.chainid == 80001) {
            _owner = vm.envAddress(
                "POLYGON_MUMBAI_SPICY_PRICE_ORACLE_MANAGER_OWNER_ADDRESS"
            );
        }

        if (block.chainid == 137) {
            _owner = vm.envAddress(
                "POLYGON_MAINNET_SPICY_PRICE_ORACLE_MANAGER_OWNER_ADDRESS"
            );
        }

        if (_owner == address(0)) {
            _owner =
                vm.envAddress("LOCAL_SPICY_PRICE_ORACLE_MANAGER_OWNER_ADDRESS");
        }

        require(_owner != address(0), "_owner mustn't be zero");

        vm.label(_owner, "owner");
    }
}
