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

/**
 * @title PriceOracle
 * @notice A simple price oracle that stores prices for asset pairs.
 * @dev This contract is meant to be updated manually and used with the OracleManager contract from Synthetix.
 */
contract PriceOracle is OwnableUpgradeable, UUPSUpgradeable, IExternalNode {
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

    function updateAssetPairPrices(AssetPairPrice[] calldata assetPairPrices)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < assetPairPrices.length; i++) {
            _assetPairPrices[assetPairPrices[i].id] = assetPairPrices[i];
        }

        emit AssetPairPricesUpdated(assetPairPrices);
    }

    function process(
        NodeOutput.Data[] memory, /* parentNodeOutputs */
        bytes memory parameters
    ) external view returns (NodeOutput.Data memory) {
        (, bytes32 id) = abi.decode(parameters, (address, bytes32));

        return NodeOutput.Data(
            _assetPairPrices[id].price, _assetPairPrices[id].timestamp, 0, 0
        );
    }

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
