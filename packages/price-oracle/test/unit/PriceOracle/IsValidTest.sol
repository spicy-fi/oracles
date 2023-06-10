// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AbstractTest} from "test/utils/AbstractTest.sol";
import {NodeOutput} from
    "@synthetixio/oracle-manager/contracts/storage/NodeOutput.sol";
import {NodeDefinition} from
    "@synthetixio/oracle-manager/contracts/storage/NodeDefinition.sol";
import {PriceOracle} from "src/PriceOracle.sol";

contract IsValidTest is AbstractTest {
    address private _priceOracleAddress;

    PriceOracle.Asset[] private _assets;
    PriceOracle.AssetPair[] private _assetPairs;
    PriceOracle.AssetPairPrice[] private _assetPairPrices;
    bytes32 private _expectedAssetPairId = bytes32(uint256(3));
    int256 private _expectedAssetPairPrice = 12e18;
    uint256 private _expectedAssetPairTimestamp = 1685795882;

    function setUp() public override {
        super.setUp();

        vm.warp(_expectedAssetPairTimestamp);

        _priceOracleAddress = address(new PriceOracle());

        vm.store(
            _priceOracleAddress,
            _slotOf("_owner", "PriceOracle"),
            bytes32(abi.encode(_owner))
        );

        _assets.push(
            PriceOracle.Asset(
                bytes32("united-states-dollar"),
                bytes32("United States Dollar"),
                bytes32("USD")
            )
        );

        _assets.push(
            PriceOracle.Asset(
                bytes32("bitcoin"), bytes32("Bitcoin"), bytes32("BTC")
            )
        );

        _assets.push(
            PriceOracle.Asset(
                bytes32("ethereum"), bytes32("Ethereum"), bytes32("ETH")
            )
        );

        _assets.push(
            PriceOracle.Asset(
                bytes32("binance-coin"), bytes32("Binance Coin"), bytes32("BNB")
            )
        );

        _assetPairs.push(
            PriceOracle.AssetPair(
                bytes32(uint256(1)),
                bytes32("bitcoin"),
                bytes32("united-states-dollar"),
                0,
                0
            )
        );

        _assetPairs.push(
            PriceOracle.AssetPair(
                bytes32(uint256(2)),
                bytes32("ethereum"),
                bytes32("united-states-dollar"),
                0,
                0
            )
        );

        _assetPairs.push(
            PriceOracle.AssetPair(
                _expectedAssetPairId,
                bytes32("binance-coin"),
                bytes32("united-states-dollar"),
                0,
                0
            )
        );

        _assetPairPrices.push(
            PriceOracle.AssetPairPrice(
                bytes32(uint256(1)), 10e18, _expectedAssetPairTimestamp
            )
        );

        _assetPairPrices.push(
            PriceOracle.AssetPairPrice(
                bytes32(uint256(2)), 11e18, _expectedAssetPairTimestamp
            )
        );
        _assetPairPrices.push(
            PriceOracle.AssetPairPrice(
                _expectedAssetPairId,
                _expectedAssetPairPrice,
                _expectedAssetPairTimestamp
            )
        );
    }

    function testIsValidShouldReturnTrue() public {
        vm.startPrank(_owner);
        PriceOracle(_priceOracleAddress).updateAssets(_assets);
        PriceOracle(_priceOracleAddress).updateAssetPairs(_assetPairs);
        PriceOracle(_priceOracleAddress).updateAssetPairPrices(_assetPairPrices);
        vm.stopPrank();

        bool valid = PriceOracle(_priceOracleAddress).isValid(
            NodeDefinition.Data(
                NodeDefinition.NodeType.EXTERNAL,
                abi.encode(_priceOracleAddress, _expectedAssetPairId),
                new bytes32[](0)
            )
        );

        assertTrue(valid);
    }

    function testIsValidShouldReturnFalseIfAnyParents() public {
        bytes32[] memory parents = new bytes32[](1);
        parents[0] = bytes32(uint256(1));

        bool valid = PriceOracle(_priceOracleAddress).isValid(
            NodeDefinition.Data(
                NodeDefinition.NodeType.EXTERNAL,
                abi.encode(_priceOracleAddress, _expectedAssetPairId),
                parents
            )
        );

        assertEq(valid, false);
    }

    function testIsValidShouldReturnFalseIfAssetPairPriceDoesNotExist()
        public
    {
        bool valid = PriceOracle(_priceOracleAddress).isValid(
            NodeDefinition.Data(
                NodeDefinition.NodeType.EXTERNAL,
                abi.encode(_priceOracleAddress, _expectedAssetPairId),
                new bytes32[](0)
            )
        );

        assertEq(valid, false);
    }

    function testIsValidShouldReturnFalseIfParametersIsEmpty() public {
        bool valid = PriceOracle(_priceOracleAddress).isValid(
            NodeDefinition.Data(
                NodeDefinition.NodeType.EXTERNAL, abi.encode(), new bytes32[](0)
            )
        );

        assertEq(valid, false);
    }

    function testIsValidShouldReturnFalseIfParametersLessThanTwo() public {
        bool valid = PriceOracle(_priceOracleAddress).isValid(
            NodeDefinition.Data(
                NodeDefinition.NodeType.EXTERNAL,
                abi.encode(address(0x1)),
                new bytes32[](0)
            )
        );

        assertEq(valid, false);
    }

    function testIsValidShouldReturnFalseIfParametersMoreThanTwo() public {
        bool valid = PriceOracle(_priceOracleAddress).isValid(
            NodeDefinition.Data(
                NodeDefinition.NodeType.EXTERNAL,
                abi.encode(
                    address(0x1), bytes32(uint256(1)), bytes32(uint256(2))
                ),
                new bytes32[](0)
            )
        );

        assertEq(valid, false);
    }
}
