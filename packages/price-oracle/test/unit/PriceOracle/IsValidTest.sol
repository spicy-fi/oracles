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

    function testIsValidShouldReturnTrue() public {
        vm.prank(_owner);
        PriceOracle(_priceOracleAddress).updateAssetPairPrices(_assetPairPrices);

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
