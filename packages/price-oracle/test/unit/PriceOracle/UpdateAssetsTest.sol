// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AbstractTest} from "test/utils/AbstractTest.sol";
import {PriceOracle} from "src/PriceOracle.sol";

contract UpdateAssetsTest is AbstractTest {
    event AssetsUpdated(PriceOracle.Asset[] assets);

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
    }

    function testUpdateAssetsShouldRevertIfZeroIdInAsset() public {
        PriceOracle.Asset memory invalidAsset = PriceOracle.Asset(
            bytes32(uint256(0)), bytes32("Random Token"), _expectedAssetSymbol
        );

        _assets.push(invalidAsset);

        vm.expectRevert(
            abi.encodeWithSelector(
                PriceOracle.InvalidAsset.selector, invalidAsset
            )
        );

        vm.prank(_owner);
        PriceOracle(_priceOracleAddress).updateAssets(_assets);
    }

    function testUpdateAssetsShouldRevertIfEmptyName() public {
        PriceOracle.Asset memory invalidAsset = PriceOracle.Asset(
            bytes32("random-token"), bytes32(0), bytes32("RDN")
        );

        _assets.push(invalidAsset);

        vm.expectRevert(
            abi.encodeWithSelector(
                PriceOracle.InvalidAsset.selector, invalidAsset
            )
        );

        vm.prank(_owner);
        PriceOracle(_priceOracleAddress).updateAssets(_assets);
    }

    function testUpdateAssetsShouldRevertIfEmptySymbol() public {
        PriceOracle.Asset memory invalidAsset = PriceOracle.Asset(
            bytes32("random-token"), bytes32("Random Token"), bytes32(0)
        );

        _assets.push(invalidAsset);

        vm.expectRevert(
            abi.encodeWithSelector(
                PriceOracle.InvalidAsset.selector, invalidAsset
            )
        );

        vm.prank(_owner);
        PriceOracle(_priceOracleAddress).updateAssets(_assets);
    }

    function testUpdateAssetsShouldRevertIfNotTheOwner() public {
        vm.expectRevert("Ownable: caller is not the owner");

        PriceOracle(_priceOracleAddress).updateAssets(_assets);
    }

    function testUpdateAssetsShouldUpdateAssets() public {
        vm.prank(_owner);
        PriceOracle(_priceOracleAddress).updateAssets(_assets);

        assertEq(
            vm.load(
                _priceOracleAddress,
                _slotOf(
                    bytes32("id"), _expectedAssetId, "_assets", "PriceOracle"
                )
            ),
            _expectedAssetId
        );

        assertEq(
            vm.load(
                _priceOracleAddress,
                _slotOf(
                    bytes32("name"), _expectedAssetId, "_assets", "PriceOracle"
                )
            ),
            _expectedAssetName
        );

        assertEq(
            vm.load(
                _priceOracleAddress,
                _slotOf(
                    bytes32("symbol"),
                    _expectedAssetId,
                    "_assets",
                    "PriceOracle"
                )
            ),
            _expectedAssetSymbol
        );
    }

    function testUpdateAssetsShouldEmitUpdateAssetsEvent() public {
        vm.expectEmit(true, true, false, true);
        emit AssetsUpdated(_assets);

        vm.prank(_owner);
        PriceOracle(_priceOracleAddress).updateAssets(_assets);
    }
}
