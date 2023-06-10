// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Vm} from "forge-std/Vm.sol";
import {PriceOracle} from "src/PriceOracle.sol";

library AssetSeeder {
    // solhint-disable-next-line const-name-snakecase
    Vm private constant vm =
        Vm(address(uint160(uint256(keccak256("hevm cheat code")))));
    uint256 private constant BATCH_SIZE = 100;

    struct RawAsset {
        string id;
        string name;
        string symbol;
    }

    function seed(address addr) internal returns (bool) {
        PriceOracle.Asset[] memory assets = read();

        uint256 batchCount = (assets.length + BATCH_SIZE - 1) / BATCH_SIZE;

        for (uint256 i = 0; i < batchCount; i++) {
            uint256 start = i * BATCH_SIZE;
            uint256 end = start + BATCH_SIZE > assets.length
                ? assets.length
                : start + BATCH_SIZE;

            PriceOracle.Asset[] memory batch =
                new PriceOracle.Asset[](end - start);

            for (uint256 j = 0; j < batch.length; j++) {
                batch[j] = assets[start + j];
            }

            PriceOracle(addr).updateAssets(batch);
        }

        return true;
    }

    function read() internal view returns (PriceOracle.Asset[] memory) {
        string memory jsonString = vm.readFile("./script/seeders/assets.json");
        bytes memory parsedString = vm.parseJson(jsonString);
        RawAsset[] memory rawAssets = abi.decode(parsedString, (RawAsset[]));

        return rawToConverted(rawAssets);
    }

    function rawToConverted(RawAsset[] memory rawAssets)
        internal
        pure
        returns (PriceOracle.Asset[] memory)
    {
        PriceOracle.Asset[] memory assets =
            new PriceOracle.Asset[](rawAssets.length);

        for (uint256 i = 0; i < rawAssets.length; i++) {
            assets[i] = rawToConverted(rawAssets[i]);
        }

        return assets;
    }

    function rawToConverted(RawAsset memory rawAsset)
        internal
        pure
        returns (PriceOracle.Asset memory)
    {
        return PriceOracle.Asset({
            id: bytes32(abi.encodePacked(rawAsset.id)),
            name: bytes32(abi.encodePacked(rawAsset.name)),
            symbol: bytes32(abi.encodePacked(rawAsset.symbol))
        });
    }
}
