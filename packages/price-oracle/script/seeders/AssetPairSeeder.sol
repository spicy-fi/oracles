// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Vm} from "forge-std/Vm.sol";
import {PriceOracle} from "src/PriceOracle.sol";

library AssetPairSeeder {
    // solhint-disable-next-line const-name-snakecase
    Vm private constant vm =
        Vm(address(uint160(uint256(keccak256("hevm cheat code")))));
    uint256 private constant BATCH_SIZE = 100;

    struct RawAssetPair {
        string baseAssetId;
        uint256 id;
        string quoteAssetId;
    }

    function seed(address addr) internal returns (bool) {
        PriceOracle.AssetPair[] memory assetPairs = read();

        uint256 batchCount = (assetPairs.length + BATCH_SIZE - 1) / BATCH_SIZE;

        for (uint256 i = 0; i < batchCount; i++) {
            uint256 start = i * BATCH_SIZE;
            uint256 end = start + BATCH_SIZE > assetPairs.length
                ? assetPairs.length
                : start + BATCH_SIZE;

            PriceOracle.AssetPair[] memory batch =
                new PriceOracle.AssetPair[](end - start);

            for (uint256 j = 0; j < batch.length; j++) {
                batch[j] = assetPairs[start + j];
            }

            PriceOracle(addr).updateAssetPairs(batch);
        }

        return true;
    }

    function read() internal view returns (PriceOracle.AssetPair[] memory) {
        string memory jsonString =
            vm.readFile("./script/seeders/assetPairs.json");
        bytes memory parsedString = vm.parseJson(jsonString);
        RawAssetPair[] memory rawAssetsPairs =
            abi.decode(parsedString, (RawAssetPair[]));

        return rawToConverted(rawAssetsPairs);
    }

    function rawToConverted(RawAssetPair[] memory rawAssetPairs)
        internal
        pure
        returns (PriceOracle.AssetPair[] memory)
    {
        PriceOracle.AssetPair[] memory assets =
            new PriceOracle.AssetPair[](rawAssetPairs.length);

        for (uint256 i = 0; i < rawAssetPairs.length; i++) {
            assets[i] = rawToConverted(rawAssetPairs[i]);
        }

        return assets;
    }

    function rawToConverted(RawAssetPair memory rawAssetPair)
        internal
        pure
        returns (PriceOracle.AssetPair memory)
    {
        PriceOracle.AssetPair memory asset = PriceOracle.AssetPair({
            id: bytes32(rawAssetPair.id),
            baseAssetId: bytes32(abi.encodePacked(rawAssetPair.baseAssetId)),
            quoteAssetId: bytes32(abi.encodePacked(rawAssetPair.quoteAssetId)),
            price: 0,
            timestamp: 0
        });

        return asset;
    }
}
