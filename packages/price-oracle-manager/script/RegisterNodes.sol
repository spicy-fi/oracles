// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// solhint-disable no-console
// solhint-disable-next-line no-global-import
import "./utils/ScriptPlus.sol";

import {NodeDefinition} from
    "@synthetixio/oracle-manager/contracts/storage/NodeDefinition.sol";
import {ReducerNode as OriginalReducerNode} from
    "@synthetixio/oracle-manager/contracts/nodes/ReducerNode.sol";
import {StaticNodeModule} from
    "@synthetixio/oracle-manager/contracts/modules/StaticNodeModule.sol";

struct ChainlinkNodeParameters {
    address addr;
    uint8 decimals;
}

struct PythNodeParameters {
    bytes32 id;
}

struct SpicyNodeParameters {
    bytes32 id;
}

struct ReducerNodeParameters {
    OriginalReducerNode.Operations mode;
    bytes32 staticNodeId;
    string symbol;
}

struct NodeType {
    NodeDefinition.NodeType nodeType;
}

struct ReducerNode {
    NodeDefinition.NodeType nodeType;
    ReducerNodeParameters parameters;
}

struct ChainlinkNode {
    NodeDefinition.NodeType nodeType;
    ChainlinkNodeParameters parameters;
}

struct PythNode {
    NodeDefinition.NodeType nodeType;
    PythNodeParameters parameters;
}

struct SpicyNode {
    NodeDefinition.NodeType nodeType;
    SpicyNodeParameters parameters;
}

contract RegisterNodes is ScriptPlus {
    address internal _spicyOracleManagerProxyAddress;
    address internal _spicyOracleProxyAddress;
    address internal _pythOracleAddress;
    string internal _nodesJsonString;

    constructor() ScriptPlus() {
        if (block.chainid == 80001) {
            _owner = vm.envAddress(
                "POLYGON_MUMBAI_SPICY_PRICE_ORACLE_MANAGER_OWNER_ADDRESS"
            );
            _spicyOracleManagerProxyAddress = vm.envAddress(
                "POLYGON_MUMBAI_SPICY_PRICE_ORACLE_MANAGER_PROXY_ADDRESS"
            );
            _spicyOracleProxyAddress =
                vm.envAddress("POLYGON_MUMBAI_SPICY_PRICE_ORACLE_PROXY_ADDRESS");
            _pythOracleAddress =
                vm.envAddress("POLYGON_MUMBAI_PYTH_ORACLE_ADDRESS");
        }

        if (block.chainid == 137) {
            _spicyOracleManagerProxyAddress = vm.envAddress(
                "POLYGON_MAINNET_SPICY_PRICE_ORACLE_MANAGER_PROXY_ADDRESS"
            );
            _spicyOracleProxyAddress = vm.envAddress(
                "POLYGON_MAINNET_SPICY_PRICE_ORACLE_PROXY_ADDRESS"
            );
            _pythOracleAddress =
                vm.envAddress("POLYGON_MAINNET_PYTH_ORACLE_ADDRESS");
        }

        if (_spicyOracleManagerProxyAddress == address(0)) {
            _spicyOracleManagerProxyAddress =
                vm.envAddress("LOCAL_SPICY_PRICE_ORACLE_MANAGER_PROXY_ADDRESS");
        }

        if (_spicyOracleProxyAddress == address(0)) {
            _spicyOracleProxyAddress =
                vm.envAddress("LOCAL_SPICY_PRICE_ORACLE_PROXY_ADDRESS");
        }

        if (_pythOracleAddress == address(0)) {
            _pythOracleAddress = vm.envAddress("LOCAL_PYTH_ORACLE_ADDRESS");
        }

        require(
            _spicyOracleManagerProxyAddress != address(0),
            "_spicyOracleManagerProxyAddress mustn't be zero"
        );
        require(
            _spicyOracleProxyAddress != address(0),
            "_spicyOracleProxyAddress mustn't be zero"
        );
        require(
            _pythOracleAddress != address(0),
            "_pythOracleAddress mustn't be zero"
        );

        vm.label(
            _spicyOracleManagerProxyAddress, "Spicy OracleManager Proxy Address"
        );
        vm.label(_spicyOracleProxyAddress, "Spicy Oracle Address");
        vm.label(_pythOracleAddress, "Pyth Oracle Address");
        _nodesJsonString = _readInput("nodes");
    }

    function run() public {
        console2.log("Deploy Contract Address:", address(this));

        vm.startBroadcast(_owner);

        console2.log("_owner:", _owner);
        console2.log("Sender Address:", msg.sender);
        console2.log("TX Origin:", tx.origin);

        vm.label(
            _spicyOracleManagerProxyAddress, "Spicy OracleManager Proxy Address"
        );
        vm.label(_spicyOracleProxyAddress, "Spicy Oracle Address");
        vm.label(_pythOracleAddress, "Pyth Oracle Address");

        string memory key = "$";
        bytes memory nodeTypeJsonBytes =
            vm.parseJson(_nodesJsonString, string.concat(key, ".[*].nodeType"));

        console.log("Registering nodes...");
        _registerNodes(nodeTypeJsonBytes, key);
        console.log("Done.");

        vm.stopBroadcast();
    }

    function _registerNodes(bytes memory nodeTypeJsonBytes, string memory key)
        internal
        returns (bytes32[] memory)
    {
        NodeDefinition.NodeType[] memory nodeTypes =
            abi.decode(nodeTypeJsonBytes, (NodeDefinition.NodeType[]));
        bytes32[] memory nodeIds = new bytes32[](nodeTypes.length);
        bytes32[] memory parentIds = new bytes32[](0);

        for (uint256 i = 0; i < nodeTypes.length; i++) {
            string memory _key = string.concat(key, ".[", vm.toString(i), "]");

            bytes memory nodeBytes = vm.parseJson(_nodesJsonString, _key);

            if (nodeTypes[i] == NodeDefinition.NodeType.REDUCER) {
                bytes memory parentNodeTypeJsonBytes = vm.parseJson(
                    _nodesJsonString,
                    string.concat(_key, ".parents.[*].nodeType")
                );

                ReducerNode memory node = abi.decode(nodeBytes, (ReducerNode));

                console.log(
                    "----------------------------------------------------"
                );
                console.log(
                    "Register Nodes for", node.parameters.symbol, "AssetPair"
                );

                if (parentNodeTypeJsonBytes.length > 0) {
                    parentIds = _registerNodes(parentNodeTypeJsonBytes, _key);
                }

                nodeIds[i] = StaticNodeModule(_spicyOracleManagerProxyAddress)
                    .getNodeId(
                    node.nodeType,
                    abi.encode(bytes32(uint256(node.parameters.mode))),
                    parentIds
                );

                bool registered = StaticNodeModule(
                    _spicyOracleManagerProxyAddress
                ).isNodeRegistered(nodeIds[i]);

                if (registered == false || nodeIds[i] == bytes32(0)) {
                    nodeIds[i] = StaticNodeModule(
                        _spicyOracleManagerProxyAddress
                    ).registerNode(
                        node.nodeType,
                        abi.encode(bytes32(uint256(node.parameters.mode))),
                        parentIds
                    );

                    console.log(
                        "Registered REDUCER NODE -", vm.toString(nodeIds[i])
                    );
                } else {
                    console.log(
                        "Already Registered REDUCER NODE -",
                        vm.toString(nodeIds[i])
                    );
                }

                bytes32 staticNodeId = StaticNodeModule(
                    _spicyOracleManagerProxyAddress
                ).getStaticNodeIdByNodeId(nodeIds[i]);

                if (staticNodeId == bytes32(0)) {
                    StaticNodeModule(_spicyOracleManagerProxyAddress)
                        .registerStaticNode(
                        node.parameters.staticNodeId, nodeIds[i]
                    );
                    console.log(
                        "Registered STATIC NODE -",
                        vm.toString(node.parameters.staticNodeId)
                    );
                } else {
                    console.log(
                        "Already Registered STATIC NODE -",
                        vm.toString(staticNodeId)
                    );
                }
            } else if (nodeTypes[i] == NodeDefinition.NodeType.CHAINLINK) {
                ChainlinkNode memory node =
                    abi.decode(nodeBytes, (ChainlinkNode));

                nodeIds[i] = StaticNodeModule(_spicyOracleManagerProxyAddress)
                    .getNodeId(
                    node.nodeType,
                    abi.encode(
                        node.parameters.addr, 0, node.parameters.decimals
                    ),
                    parentIds
                );

                bool registered = StaticNodeModule(
                    _spicyOracleManagerProxyAddress
                ).isNodeRegistered(nodeIds[i]);

                if (registered == false || nodeIds[i] == bytes32(0)) {
                    nodeIds[i] = StaticNodeModule(
                        _spicyOracleManagerProxyAddress
                    ).registerNode(
                        node.nodeType,
                        abi.encode(
                            node.parameters.addr, 0, node.parameters.decimals
                        ),
                        parentIds
                    );

                    console.log(
                        "Registered CHAINLINK NODE -", vm.toString(nodeIds[i])
                    );
                } else {
                    console.log(
                        "Already Registered CHAINLINK NODE -",
                        vm.toString(nodeIds[i])
                    );
                }
            } else if (nodeTypes[i] == NodeDefinition.NodeType.PYTH) {
                PythNode memory node = abi.decode(nodeBytes, (PythNode));

                nodeIds[i] = StaticNodeModule(_spicyOracleManagerProxyAddress)
                    .getNodeId(
                    node.nodeType,
                    abi.encode(_pythOracleAddress, node.parameters.id, false),
                    parentIds
                );

                bool registered = StaticNodeModule(
                    _spicyOracleManagerProxyAddress
                ).isNodeRegistered(nodeIds[i]);

                if (registered == false || nodeIds[i] == bytes32(0)) {
                    nodeIds[i] = StaticNodeModule(
                        _spicyOracleManagerProxyAddress
                    ).registerNode(
                        node.nodeType,
                        abi.encode(
                            _pythOracleAddress, node.parameters.id, false
                        ),
                        parentIds
                    );

                    console.log(
                        "Registered PYTH NODE -", vm.toString(nodeIds[i])
                    );
                } else {
                    console.log(
                        "Already Registered PYTH NODE -",
                        vm.toString(nodeIds[i])
                    );
                }
            } else if (nodeTypes[i] == NodeDefinition.NodeType.EXTERNAL) {
                SpicyNode memory node = abi.decode(nodeBytes, (SpicyNode));

                nodeIds[i] = StaticNodeModule(_spicyOracleManagerProxyAddress)
                    .getNodeId(
                    node.nodeType,
                    abi.encode(_spicyOracleProxyAddress, node.parameters.id),
                    parentIds
                );

                bool registered = StaticNodeModule(
                    _spicyOracleManagerProxyAddress
                ).isNodeRegistered(nodeIds[i]);

                if (registered == false || nodeIds[i] == bytes32(0)) {
                    nodeIds[i] = StaticNodeModule(
                        _spicyOracleManagerProxyAddress
                    ).registerNode(
                        node.nodeType,
                        abi.encode(_spicyOracleProxyAddress, node.parameters.id),
                        parentIds
                    );

                    console.log(
                        "Registered EXTERNAL (SPICY) NODE -",
                        vm.toString(nodeIds[i])
                    );
                } else {
                    console.log(
                        "Already Registered EXTERNAL (SPICY) NODE -",
                        vm.toString(nodeIds[i])
                    );
                }
            }
        }

        return nodeIds;
    }

    function _readInput(string memory input)
        internal
        view
        returns (string memory)
    {
        string memory inputDir =
            string.concat(vm.projectRoot(), "/script/input/");
        string memory chainDir = string.concat(vm.toString(block.chainid), "/");
        string memory file = string.concat(input, ".json");
        return vm.readFile(string.concat(inputDir, chainDir, file));
    }
}
