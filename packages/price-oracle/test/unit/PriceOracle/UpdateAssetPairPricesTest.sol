// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AbstractTest} from "test/utils/AbstractTest.sol";
import {PriceOracle} from "src/PriceOracle.sol";

contract UpdateAssetPairPricesTest is AbstractTest {
    event AssetPairPricesUpdated(PriceOracle.AssetPairPrice[] assetPairPrices);

    address private _priceOracleAddress;

    PriceOracle.AssetPairPrice[] private _assetPairPrices;
    bytes32 private _expectedAssetPairId = bytes32(abi.encodePacked("USDT/USD"));
    int256 private _expectedAssetPairPrice = 12e18;
    uint256 private _expectedAssetPairTimestamp = 1666668;

    function setUp() public override {
        super.setUp();

        _priceOracleAddress = address(new PriceOracle());

        vm.store(
            _priceOracleAddress,
            _slotOf("_owner", "PriceOracle"),
            bytes32(abi.encode(_owner))
        );

        _assetPairPrices.push(
            PriceOracle.AssetPairPrice(bytes32(uint256(0)), 10e18, 1666666)
        );

        _assetPairPrices.push(
            PriceOracle.AssetPairPrice(bytes32(uint256(1)), 11e18, 1666667)
        );
        _assetPairPrices.push(
            PriceOracle.AssetPairPrice(
                _expectedAssetPairId,
                _expectedAssetPairPrice,
                _expectedAssetPairTimestamp
            )
        );
    }

    function testUpdateAssetPairPricesShouldRevertIfNotTheOwner() public {
        vm.expectRevert("Ownable: caller is not the owner");

        PriceOracle(_priceOracleAddress).updateAssetPairPrices(_assetPairPrices);
    }

    function testUpdateAssetPairPricesShouldUpdateAssetPairPrices() public {
        vm.prank(_owner);
        PriceOracle(_priceOracleAddress).updateAssetPairPrices(_assetPairPrices);

        assertEq(
            vm.load(
                _priceOracleAddress,
                _slotOf(
                    bytes32("id"),
                    _expectedAssetPairId,
                    "_assetPairPrices",
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
                            "_assetPairPrices",
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
                        "_assetPairPrices",
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
        vm.expectEmit(true, true, false, true);
        emit AssetPairPricesUpdated(_assetPairPrices);

        vm.prank(_owner);
        PriceOracle(_priceOracleAddress).updateAssetPairPrices(_assetPairPrices);
    }
}
