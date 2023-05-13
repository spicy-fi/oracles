// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Vm} from "forge-std/Vm.sol";
import {JsonWriter} from "solidity-json-writer/JsonWriter.sol";

library LibAddressCache {
    using JsonWriter for JsonWriter.Json;

    string public constant CACHE_FILE = "./.addressCache.json";

    /// custom:todo is it possible to inherit this from Vm.sol - feels like duplication of code
    address public constant VM_ADDRESS =
        address(bytes20(uint160(uint256(keccak256("hevm cheat code")))));

    // solhint-disable-next-line const-name-snakecase
    Vm internal constant vm = Vm(VM_ADDRESS);

    function generateKey(uint256 chainId, string memory contractName)
        internal
        pure
        returns (string memory key)
    {
        key = string.concat(".", vm.toString(chainId), ".", contractName);
    }

    function getByKey(string memory key) internal view returns (address addr) {
        string memory data = vm.readFile(CACHE_FILE);
        bytes memory parsed = vm.parseJson(data, key);
        addr = abi.decode(parsed, (address));
    }

    /// @custom:todo somehow remove hardcoded chains and contract names?
    function getAll()
        internal
        view
        returns (
            uint256[] memory chains,
            string[] memory contracts,
            address[] memory contractAddresses
        )
    {
        chains = new uint256[](3);
        chains[0] = 137;
        chains[1] = 80001;
        chains[2] = 31337;

        contracts = new string[](4);
        contracts[0] = "CryptoChefs";
        contracts[1] = "AROMAProxy";
        contracts[2] = "Multicall2";
        contracts[3] = "SteakHouse";
        contracts[3] = "SpicyOracle";

        contractAddresses = new address[](chains.length * contracts.length);

        uint256 counter;

        for (uint256 ch = 0; ch < chains.length; ch++) {
            for (uint256 co = 0; co < contracts.length; co++) {
                contractAddresses[counter] =
                    getByKey(generateKey(chains[ch], contracts[co]));

                counter++;
            }
        }
    }

    function add(string memory name, address addr) internal {
        JsonWriter.Json memory writer;
        uint256[] memory chains;
        string[] memory contracts;
        address[] memory contractAddresses;

        (chains, contracts, contractAddresses) = getAll();

        writer = writer.writeStartObject();
        uint256 writerCounter;

        address contractAddress;

        for (uint256 ch = 0; ch < chains.length; ch++) {
            writer = writer.writeStartObject(vm.toString(chains[ch]));

            for (uint256 co = 0; co < contracts.length; co++) {
                contractAddress = contractAddresses[writerCounter];

                if (
                    (
                        keccak256(abi.encodePacked((name)))
                            == keccak256(abi.encodePacked((contracts[co])))
                    ) && chains[ch] == block.chainid
                ) {
                    contractAddress = addr;
                }

                writer = writer.writeStartObject(contracts[co]);
                writer = writer.writeAddressProperty("address", contractAddress);
                writer = writer.writeEndObject();

                writerCounter++;
            }

            writer = writer.writeEndObject();
        }

        writer = writer.writeEndObject();

        vm.writeFile(CACHE_FILE, writer.value);
    }
}
