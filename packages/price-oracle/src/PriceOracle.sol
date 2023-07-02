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
    error InvalidAsset(Asset asset);
    error InvalidAssetPair(AssetPair assetPair);
    error InvalidAssetPairPrice(AssetPairPrice assetPairPrice);
    error AssetPairDoesNotExist(bytes32 assetPairId);

    event AssetsUpdated(Asset[] assets);
    event AssetPairsUpdated(AssetPair[] assetPairs);
    event AssetPairPricesUpdated(AssetPairPrice[] assetPairPrices);

    struct Asset {
        bytes32 id;
        bytes32 name;
        bytes32 symbol;
    }

    struct AssetPair {
        bytes32 id;
        bytes32 baseAssetId;
        bytes32 quoteAssetId;
        int256 price;
        uint256 timestamp;
    }

    struct AssetPairPrice {
        bytes32 id;
        int256 price;
        uint256 timestamp;
    }

    mapping(bytes32 => Asset) private _assets;
    mapping(bytes32 => AssetPair) private _assetPairs;

    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    // solhint-disable-next-line no-empty-blocks
    function _authorizeUpgrade(address) internal override onlyOwner {}

    function getAsset(bytes32 id) external view returns (Asset memory) {
        return _assets[id];
    }

    function updateAssets(Asset[] calldata assets) external onlyOwner {
        for (uint256 i = 0; i < assets.length; i++) {
            if (
                assets[i].id == 0 || assets[i].name == 0
                    || assets[i].symbol == 0
            ) {
                revert InvalidAsset(assets[i]);
            }

            _assets[assets[i].id] = assets[i];
        }

        emit AssetsUpdated(assets);
    }

    function getAssetPair(bytes32 id)
        external
        view
        returns (AssetPair memory)
    {
        return _assetPairs[id];
    }

    function updateAssetPairs(AssetPair[] calldata assetPairs)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < assetPairs.length; i++) {
            if (
                assetPairs[i].id == 0 || assetPairs[i].baseAssetId == 0
                    || assetPairs[i].quoteAssetId == 0
                    || _assets[assetPairs[i].baseAssetId].id == 0
                    || _assets[assetPairs[i].quoteAssetId].id == 0
            ) {
                revert InvalidAssetPair(assetPairs[i]);
            }

            _assetPairs[assetPairs[i].id] = assetPairs[i];
        }

        emit AssetPairsUpdated(assetPairs);
    }

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

            if (_assetPairs[assetPairPrices[i].id].id == 0) {
                revert AssetPairDoesNotExist(assetPairPrices[i].id);
            }

            _assetPairs[assetPairPrices[i].id].price = assetPairPrices[i].price;
            _assetPairs[assetPairPrices[i].id].timestamp =
                assetPairPrices[i].timestamp;
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
            _assetPairs[id].price, _assetPairs[id].timestamp, 0, 0
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

        if (_assetPairs[id].id == 0) {
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
