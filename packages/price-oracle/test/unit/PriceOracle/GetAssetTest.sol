// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AbstractTest} from "test/utils/AbstractTest.sol";
import {PriceOracle} from "src/PriceOracle.sol";

contract GetAssetTest is AbstractTest {
    address private _priceOracleAddress;

    PriceOracle.Asset[] private _assets;
    bytes32 private _expectedAssetId = bytes32("binance-coin");
    bytes32 private _expectedAssetSymbol = bytes32("BNB");
    bytes32 private _expectedAssetName = bytes32("Binance Coin");

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
                _expectedAssetId, _expectedAssetName, _expectedAssetSymbol
            )
        );

        vm.prank(_owner);
        PriceOracle(_priceOracleAddress).updateAssets(_assets);
    }

    function testGetAssetShouldReturnAsset() public {
        PriceOracle.Asset memory asset =
            PriceOracle(_priceOracleAddress).getAsset(_expectedAssetId);

        assertEq(asset.id, _expectedAssetId);
        assertEq(asset.name, _expectedAssetName);
        assertEq(asset.symbol, _expectedAssetSymbol);
    }

    function testGetAssetShouldReturnEmptyAsset() public {
        PriceOracle.Asset memory asset =
            PriceOracle(_priceOracleAddress).getAsset(bytes32("random"));

        assertEq(asset.id, bytes32(""));
        assertEq(asset.name, bytes32(""));
        assertEq(asset.symbol, bytes32(""));
    }
}
