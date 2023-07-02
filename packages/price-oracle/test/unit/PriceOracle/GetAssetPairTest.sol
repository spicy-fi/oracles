// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AbstractTest} from "test/utils/AbstractTest.sol";
import {PriceOracle} from "src/PriceOracle.sol";

contract GetAssetPairTest is AbstractTest {
    address private _priceOracleAddress;

    PriceOracle.Asset[] private _assets;
    PriceOracle.AssetPair[] private _assetPairs;
    bytes32 private _expectedAssetPairId = bytes32(uint256(3));
    bytes32 private _expectedAssetPairBaseAssetId = bytes32("binance-coin");
    bytes32 private _expectedAssetPairQuoteAssetId =
        bytes32("united-states-dollar");
    int256 private _expectedAssetPairPrice = int256(3453);
    uint256 private _expectedAssetPairTimestamp = uint256(324243);

    function setUp() public override {
        super.setUp();

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
                _expectedAssetPairBaseAssetId,
                bytes32("Binance Coin"),
                bytes32("BNB")
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
                _expectedAssetPairBaseAssetId,
                _expectedAssetPairQuoteAssetId,
                _expectedAssetPairPrice,
                _expectedAssetPairTimestamp
            )
        );

        vm.prank(_owner);
        PriceOracle(_priceOracleAddress).updateAssets(_assets);

        vm.prank(_owner);
        PriceOracle(_priceOracleAddress).updateAssetPairs(_assetPairs);
    }

    function testGetAssetPairShouldReturnAssetPair() public {
        PriceOracle.AssetPair memory assetPair =
            PriceOracle(_priceOracleAddress).getAssetPair(_expectedAssetPairId);

        assertEq(assetPair.id, _expectedAssetPairId);
        assertEq(assetPair.baseAssetId, _expectedAssetPairBaseAssetId);
        assertEq(assetPair.quoteAssetId, _expectedAssetPairQuoteAssetId);
        assertEq(assetPair.price, _expectedAssetPairPrice);
        assertEq(assetPair.timestamp, _expectedAssetPairTimestamp);
    }

    function testGetAssetPairShouldReturnEmptyAssetPair() public {
        PriceOracle.AssetPair memory assetPair =
            PriceOracle(_priceOracleAddress).getAssetPair(bytes32("random"));

        assertEq(assetPair.id, bytes32(""));
        assertEq(assetPair.baseAssetId, bytes32(""));
        assertEq(assetPair.quoteAssetId, bytes32(""));
        assertEq(assetPair.price, int256(0));
        assertEq(assetPair.timestamp, uint256(0));
    }
}
