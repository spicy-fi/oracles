// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// solhint-disable no-console
// solhint-disable-next-line no-global-import
import "./utils/ScriptPlus.sol";

import {LibAddressCache} from "./utils/LibAddressCache.sol";
import {PriceOracle} from "src/PriceOracle.sol";
import {PriceOracleProxy} from "src/PriceOracleProxy.sol";

contract DeployPriceOracle is ScriptPlus {
    address private _priceOracleProxyAddress;
    address private _priceOracleImplementationAddress;

    /**
     * @notice deploy a price oracle contract
     * @param newProxy if true, deploy a new proxy, otherwise use the existing proxy
     */
    function run(bool newProxy) public {
        console2.log("Deploy Contract Address:", address(this));

        vm.startBroadcast(_owner);

        console2.log("_owner:", _owner);
        console2.log("Sender Address:", msg.sender);
        // solhint-disable-next-line avoid-tx-origin
        console2.log("TX Origin:", tx.origin);

        if (newProxy == true) {
            (_priceOracleProxyAddress, _priceOracleImplementationAddress) =
                _deployPriceOracleWithProxy();

            vm.label(_priceOracleProxyAddress, "PriceOracle Proxy Address");

            vm.label(
                _priceOracleImplementationAddress,
                "PriceOracle Implementation Address"
            );

            _initPriceOracle(_priceOracleProxyAddress);

            LibAddressCache.add("PriceOracle", _priceOracleProxyAddress);
            console2.log(
                "New PriceOracle Proxy Address:", _priceOracleProxyAddress
            );
        } else {
            _priceOracleProxyAddress = LibAddressCache.getByKey(
                LibAddressCache.generateKey(block.chainid, "PriceOracle")
            );

            _priceOracleImplementationAddress =
                _deployPriceOracleForProxy(_priceOracleProxyAddress);

            vm.label(_priceOracleProxyAddress, "PriceOracle Proxy Address");

            vm.label(
                _priceOracleImplementationAddress,
                "PriceOracle Implementation Address"
            );

            console2.log("PriceOracle Proxy Address:", _priceOracleProxyAddress);
        }

        console2.log(
            "New PriceOracle Implementation Address:",
            _priceOracleImplementationAddress
        );

        vm.stopBroadcast();
    }

    /// @notice deploys a price oracle contract
    function _deployPriceOracle()
        internal
        returns (address priceOracleImplementationAddress)
    {
        priceOracleImplementationAddress = address(new PriceOracle());
    }

    /// @notice deploys an price oracle proxy contract
    function _deployPriceOracleProxy(address priceOracleImplementationAddress)
        internal
        returns (address priceOracleProxyAddress)
    {
        priceOracleProxyAddress = address(
            new PriceOracleProxy(
            priceOracleImplementationAddress,
            ""
            )
        );
    }

    /// @notice deploys an price oracle contract with a proxy
    function _deployPriceOracleWithProxy()
        internal
        returns (
            address priceOracleProxyAddress,
            address priceOracleImplementationAddress
        )
    {
        priceOracleImplementationAddress = _deployPriceOracle();
        priceOracleProxyAddress =
            _deployPriceOracleProxy(priceOracleImplementationAddress);
    }

    /// @notice deploys and upgrades an price oracle contract in a proxy
    function _deployPriceOracleForProxy(address priceOracleProxyAddress)
        internal
        returns (address priceOracleImplementationAddress)
    {
        priceOracleImplementationAddress = _deployPriceOracle();

        PriceOracle(priceOracleProxyAddress).upgradeTo(
            priceOracleImplementationAddress
        );
    }

    function _initPriceOracle(address priceOracleProxyAddress) internal {
        PriceOracle(priceOracleProxyAddress).initialize();
    }
}
