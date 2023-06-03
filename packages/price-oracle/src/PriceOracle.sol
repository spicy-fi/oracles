//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Initializable} from
    "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from
    "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from
    "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {IExternalNode} from
    "@synthetixio/oracle-manager/contracts/interfaces/external/IExternalNode.sol";
import {NodeDefinition} from
    "@synthetixio/oracle-manager/contracts/storage/NodeDefinition.sol";
import {NodeOutput} from
    "@synthetixio/oracle-manager/contracts/storage/NodeOutput.sol";

/// @title PriceOracle
/// @notice A simple price oracle that stores prices for asset pairs.
/// @dev This contract is meant to be updated manually and used with the OracleManager contract from Synthetix.
contract PriceOracle is
    Initializable,
    OwnableUpgradeable,
    UUPSUpgradeable,
    IExternalNode
{
    error InvalidAssetPairPrice(AssetPairPrice assetPairPrice);

    event AssetPairPricesUpdated(AssetPairPrice[] assetPairPrices);

    struct AssetPairPrice {
        bytes32 id;
        int256 price;
        uint256 timestamp;
    }

    mapping(bytes32 => AssetPairPrice) private _assetPairPrices;

    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    // solhint-disable-next-line no-empty-blocks
    function _authorizeUpgrade(address) internal override onlyOwner {}

    /// @dev Updates the price for a list of asset pairs. Can only be called by the contract owner.
    /// @param assetPairPrices The list of new asset pair prices to update.
    function updateAssetPairPrices(AssetPairPrice[] calldata assetPairPrices)
        external
        onlyOwner
    {
        /// @dev Miners can manipulate block timestamp to an extent of approx.
        /// few seconds, which is enough to affect business logic depending on a
        /// second-level precision but since this logic depends on much longer
        /// period, we suppress the warning.
        // solhint-disable not-rely-on-time
        // slither-disable-start timestamp
        uint256 oneHourAgo = block.timestamp - 1 hours;
        // solhint-enable not-rely-on-time
        // slither-disable-end timestamp

        for (uint256 i = 0; i < assetPairPrices.length; i++) {
            if (
                assetPairPrices[i].id == 0 || assetPairPrices[i].price == 0
                    || assetPairPrices[i].timestamp < oneHourAgo
            ) {
                revert InvalidAssetPairPrice(assetPairPrices[i]);
            }

            _assetPairPrices[assetPairPrices[i].id] = assetPairPrices[i];
        }

        emit AssetPairPricesUpdated(assetPairPrices);
    }

    /// @dev Processes oracle update request.
    /// @param parameters Oracle update parameters.
    /// @return NodeOutput.Data.
    function process(
        NodeOutput.Data[] memory, /* parentNodeOutputs */
        bytes memory parameters
    ) external view returns (NodeOutput.Data memory) {
        (, bytes32 id) = abi.decode(parameters, (address, bytes32));

        return NodeOutput.Data(
            _assetPairPrices[id].price, _assetPairPrices[id].timestamp, 0, 0
        );
    }

    /// @dev Check if node definition is valid.
    /// @param nodeDefinition The node definition to check.
    /// @return bool indicating if node definition is valid.
    function isValid(NodeDefinition.Data memory nodeDefinition)
        external
        view
        returns (bool)
    {
        if (nodeDefinition.parents.length > 0) {
            return false;
        }

        if (nodeDefinition.parameters.length != 32 * 2) {
            return false;
        }

        (, bytes32 id) =
            abi.decode(nodeDefinition.parameters, (address, bytes32));

        if (_assetPairPrices[id].id == 0) {
            return false;
        }

        return true;
    }

    function supportsInterface(bytes4 interfaceID)
        external
        pure
        returns (bool)
    {
        return type(IExternalNode).interfaceId == interfaceID;
    }
}
