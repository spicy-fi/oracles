// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AbstractTest} from "test/utils/AbstractTest.sol";
import {NodeOutput} from
    "@synthetixio/oracle-manager/contracts/storage/NodeOutput.sol";
import {PriceOracle} from "src/PriceOracle.sol";

contract ProcessTest is AbstractTest {
    address private _priceOracleAddress;

    PriceOracle.AssetPairPrice[] private _expectedAssetPairPrices;
    bytes32 private _expectedAssetPairId = bytes32(uint256(4));
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

        _expectedAssetPairPrices.push(
            PriceOracle.AssetPairPrice(
                bytes32(uint256(1)), 10e18, _expectedAssetPairTimestamp
            )
        );

        _expectedAssetPairPrices.push(
            PriceOracle.AssetPairPrice(
                bytes32(uint256(2)), 11e18, _expectedAssetPairTimestamp
            )
        );
        _expectedAssetPairPrices.push(
            PriceOracle.AssetPairPrice(
                _expectedAssetPairId,
                _expectedAssetPairPrice,
                _expectedAssetPairTimestamp
            )
        );
    }

    function testProcessShouldReturnPriceAndLastUpdated() public {
        vm.prank(_owner);
        PriceOracle(_priceOracleAddress).updateAssetPairPrices(
            _expectedAssetPairPrices
        );

        NodeOutput.Data memory data = PriceOracle(_priceOracleAddress).process(
            new NodeOutput.Data[](0),
            abi.encode(_priceOracleAddress, _expectedAssetPairId)
        );

        assertEq(data.price, _expectedAssetPairPrice);

        assertEq(data.timestamp, _expectedAssetPairTimestamp);
    }
}
