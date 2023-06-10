// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AbstractTest} from "test/utils/AbstractTest.sol";
import {PriceOracle} from "src/PriceOracle.sol";

contract UpdateAssetPairPricesTest is AbstractTest {
    event AssetPairPricesUpdated(PriceOracle.AssetPairPrice[] assetPairPrices);

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

    function testUpdateAssetPairPricesShouldRevertIfZeroIdInAssetPairPrices()
        public
    {
        PriceOracle.AssetPairPrice memory invalidAssetPairPrice = PriceOracle
            .AssetPairPrice(bytes32(uint256(0)), 11e18, _expectedAssetPairTimestamp);

        _assetPairPrices.push(invalidAssetPairPrice);

        vm.startPrank(_owner);
        PriceOracle(_priceOracleAddress).updateAssets(_assets);
        PriceOracle(_priceOracleAddress).updateAssetPairs(_assetPairs);

        vm.expectRevert(
            abi.encodeWithSelector(
                PriceOracle.InvalidAssetPairPrice.selector,
                invalidAssetPairPrice
            )
        );
        PriceOracle(_priceOracleAddress).updateAssetPairPrices(_assetPairPrices);
        vm.stopPrank();
    }

    function testUpdateAssetPairPricesShouldRevertIfNonExistingIdInAssetPairPrices(
    ) public {
        PriceOracle.AssetPairPrice memory invalidAssetPairPrice = PriceOracle
            .AssetPairPrice(
            bytes32(uint256(99)), 11e18, _expectedAssetPairTimestamp
        );

        _assetPairPrices.push(invalidAssetPairPrice);

        vm.startPrank(_owner);
        PriceOracle(_priceOracleAddress).updateAssets(_assets);
        PriceOracle(_priceOracleAddress).updateAssetPairs(_assetPairs);

        vm.expectRevert(
            abi.encodeWithSelector(
                PriceOracle.AssetPairDoesNotExist.selector,
                invalidAssetPairPrice.id
            )
        );
        PriceOracle(_priceOracleAddress).updateAssetPairPrices(_assetPairPrices);
        vm.stopPrank();
    }

    function testUpdateAssetPairPricesShouldRevertIfInvalidPriceInAssetPairPrices(
    ) public {
        PriceOracle.AssetPairPrice memory invalidAssetPairPrice = PriceOracle
            .AssetPairPrice(_expectedAssetPairId, 0, _expectedAssetPairTimestamp);

        _assetPairPrices.push(invalidAssetPairPrice);

        vm.startPrank(_owner);
        PriceOracle(_priceOracleAddress).updateAssets(_assets);
        PriceOracle(_priceOracleAddress).updateAssetPairs(_assetPairs);

        vm.expectRevert(
            abi.encodeWithSelector(
                PriceOracle.InvalidAssetPairPrice.selector,
                invalidAssetPairPrice
            )
        );
        PriceOracle(_priceOracleAddress).updateAssetPairPrices(_assetPairPrices);
        vm.stopPrank();
    }

    function testUpdateAssetPairPricesShouldRevertIfInvalidTimestampInAssetPairPrices(
    ) public {
        PriceOracle.AssetPairPrice memory invalidAssetPairPrice = PriceOracle
            .AssetPairPrice(
            _expectedAssetPairId, 10e18, _expectedAssetPairTimestamp - 3 hours
        );

        _assetPairPrices.push(invalidAssetPairPrice);

        vm.startPrank(_owner);
        PriceOracle(_priceOracleAddress).updateAssets(_assets);
        PriceOracle(_priceOracleAddress).updateAssetPairs(_assetPairs);

        vm.expectRevert(
            abi.encodeWithSelector(
                PriceOracle.InvalidAssetPairPrice.selector,
                invalidAssetPairPrice
            )
        );
        PriceOracle(_priceOracleAddress).updateAssetPairPrices(_assetPairPrices);
        vm.stopPrank();
    }

    function testUpdateAssetPairPricesShouldRevertIfNotTheOwner() public {
        vm.expectRevert("Ownable: caller is not the owner");

        PriceOracle(_priceOracleAddress).updateAssetPairPrices(_assetPairPrices);
    }

    function testUpdateAssetPairPricesShouldUpdateAssetPairPrices() public {
        vm.startPrank(_owner);
        PriceOracle(_priceOracleAddress).updateAssets(_assets);
        PriceOracle(_priceOracleAddress).updateAssetPairs(_assetPairs);
        PriceOracle(_priceOracleAddress).updateAssetPairPrices(_assetPairPrices);
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
            int256(
                uint256(
                    vm.load(
                        _priceOracleAddress,
                        _slotOf(
                            bytes32("price"),
                            _expectedAssetPairId,
                            "_assetPairs",
                            "PriceOracle"
                        )
                    )
                )
            ),
            _expectedAssetPairPrice
        );

        assertEq(
            uint256(
                vm.load(
                    _priceOracleAddress,
                    _slotOf(
                        bytes32("timestamp"),
                        _expectedAssetPairId,
                        "_assetPairs",
                        "PriceOracle"
                    )
                )
            ),
            _expectedAssetPairTimestamp
        );
    }

    function testUpdateAssetPairPricesShouldEmitUpdateAssetPairPricesEvent()
        public
    {
        vm.startPrank(_owner);
        PriceOracle(_priceOracleAddress).updateAssets(_assets);
        PriceOracle(_priceOracleAddress).updateAssetPairs(_assetPairs);

        vm.expectEmit(true, true, false, true);
        emit AssetPairPricesUpdated(_assetPairPrices);
        PriceOracle(_priceOracleAddress).updateAssetPairPrices(_assetPairPrices);
        vm.stopPrank();
    }
}
