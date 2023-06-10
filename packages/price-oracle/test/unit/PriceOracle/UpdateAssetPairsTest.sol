// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AbstractTest} from "test/utils/AbstractTest.sol";
import {PriceOracle} from "src/PriceOracle.sol";

contract UpdateAssetPairsTest is AbstractTest {
    event AssetPairsUpdated(PriceOracle.AssetPair[] assetPairs);

    address private _priceOracleAddress;

    PriceOracle.Asset[] private _assets;
    PriceOracle.AssetPair[] private _assetPairs;
    bytes32 private _expectedAssetPairId = bytes32(uint256(3));
    bytes32 private _expectedAssetPairBaseAssetId = bytes32("binance-coin");
    bytes32 private _expectedAssetPairQuoteAssetId =
        bytes32("united-states-dollar");

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
                0,
                0
            )
        );
    }

    function testUpdateAssetPairsShouldRevertIfZeroIdInAssetPairs() public {
        PriceOracle.AssetPair memory invalidAssetPair = PriceOracle.AssetPair(
            bytes32(uint256(0)),
            _expectedAssetPairBaseAssetId,
            _expectedAssetPairQuoteAssetId,
            0,
            0
        );

        _assetPairs.push(invalidAssetPair);

        vm.startPrank(_owner);
        PriceOracle(_priceOracleAddress).updateAssets(_assets);

        vm.expectRevert(
            abi.encodeWithSelector(
                PriceOracle.InvalidAssetPair.selector, invalidAssetPair
            )
        );

        PriceOracle(_priceOracleAddress).updateAssetPairs(_assetPairs);
        vm.stopPrank();
    }

    function testUpdateAssetPairsShouldRevertIfInvalidBaseAssetId() public {
        PriceOracle.AssetPair memory invalidAssetPair = PriceOracle.AssetPair(
            bytes32(uint256(1)),
            bytes32("whatever"),
            _expectedAssetPairQuoteAssetId,
            0,
            0
        );

        _assetPairs.push(invalidAssetPair);

        vm.startPrank(_owner);
        PriceOracle(_priceOracleAddress).updateAssets(_assets);

        vm.expectRevert(
            abi.encodeWithSelector(
                PriceOracle.InvalidAssetPair.selector, invalidAssetPair
            )
        );

        PriceOracle(_priceOracleAddress).updateAssetPairs(_assetPairs);
        vm.stopPrank();
    }

    function testUpdateAssetPairsShouldRevertIfInvalidQuoteAssetId() public {
        PriceOracle.AssetPair memory invalidAssetPair = PriceOracle.AssetPair(
            bytes32(uint256(1)),
            _expectedAssetPairBaseAssetId,
            bytes32("whatever"),
            0,
            0
        );

        _assetPairs.push(invalidAssetPair);

        vm.startPrank(_owner);
        PriceOracle(_priceOracleAddress).updateAssets(_assets);

        vm.expectRevert(
            abi.encodeWithSelector(
                PriceOracle.InvalidAssetPair.selector, invalidAssetPair
            )
        );

        PriceOracle(_priceOracleAddress).updateAssetPairs(_assetPairs);
        vm.stopPrank();
    }

    function testUpdateAssetPairsShouldRevertIfNotTheOwner() public {
        vm.expectRevert("Ownable: caller is not the owner");

        PriceOracle(_priceOracleAddress).updateAssetPairs(_assetPairs);
    }

    function testUpdateAssetPairsShouldUpdateAssetPairs() public {
        vm.startPrank(_owner);
        PriceOracle(_priceOracleAddress).updateAssets(_assets);
        PriceOracle(_priceOracleAddress).updateAssetPairs(_assetPairs);
        vm.stopPrank();

        assertEq(
            vm.load(
                _priceOracleAddress,
                _slotOf(
                    bytes32("id"),
                    _expectedAssetPairId,
                    "_assetPairs",
                    "PriceOracle"
                )
            ),
            _expectedAssetPairId
        );

        assertEq(
            vm.load(
                _priceOracleAddress,
                _slotOf(
                    bytes32("baseAssetId"),
                    _expectedAssetPairId,
                    "_assetPairs",
                    "PriceOracle"
                )
            ),
            _expectedAssetPairBaseAssetId
        );

        assertEq(
            vm.load(
                _priceOracleAddress,
                _slotOf(
                    bytes32("quoteAssetId"),
                    _expectedAssetPairId,
                    "_assetPairs",
                    "PriceOracle"
                )
            ),
            _expectedAssetPairQuoteAssetId
        );
    }

    function testUpdateAssetPairsShouldEmitUpdateAssetPairPricesEvent()
        public
    {
        vm.startPrank(_owner);
        PriceOracle(_priceOracleAddress).updateAssets(_assets);

        vm.expectEmit(true, true, false, true);
        emit AssetPairsUpdated(_assetPairs);

        PriceOracle(_priceOracleAddress).updateAssetPairs(_assetPairs);
        vm.stopPrank();
    }
}
