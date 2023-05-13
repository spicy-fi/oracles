// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

abstract contract Slots {
    function _eq(string memory a, string memory b)
        internal
        pure
        returns (bool)
    {
        return (
            keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b)))
        );
    }

    function _slot(uint256 slot) internal pure returns (bytes32) {
        return bytes32(slot);
    }

    function _slot(bytes32 slot) internal pure returns (bytes32) {
        return slot;
    }

    function _slotOfSlot(bytes32 slotOf, bytes32 slot)
        internal
        pure
        returns (bytes32)
    {
        return _slot(uint256(slot) + uint256(slotOf));
    }

    function _slotOfSlot(uint256 slotOf, uint256 slot)
        internal
        pure
        returns (bytes32)
    {
        return _slot(slot + slotOf);
    }

    function _slotOfSlot(uint256 slotOf, bytes32 slot)
        internal
        pure
        returns (bytes32)
    {
        return _slot(uint256(slot) + slotOf);
    }

    function _slotOfSlot(bytes32 slotOf, uint256 slot)
        internal
        pure
        returns (bytes32)
    {
        return _slot(slot + uint256(slotOf));
    }

    function _slotOfKeyOfSlot(uint256 slotOfKeyOf, bytes32 slot)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(abi.encode(slotOfKeyOf, slot));
    }

    function _slotOfKeyOfSlot(bytes32 slotOfKeyOf, bytes32 slot)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(abi.encode(slotOfKeyOf, slot));
    }

    function _slotOfStorage(uint256 slot, string memory store)
        internal
        pure
        returns (bytes32)
    {
        bytes32 baseSlot;

        if (_eq(store, "PriceOracle")) {
            baseSlot = 0;
        }

        return _slotOfSlot(slot, baseSlot);
    }

    function _slotOfStorage(bytes32 slot, string memory store)
        internal
        pure
        returns (bytes32)
    {
        return _slotOfStorage(uint256(slot), store);
    }

    function _slotOf(bytes32 a1, bytes32 a2, string memory a3, string memory a4)
        internal
        pure
        returns (bytes32 slot)
    {
        if (
            a1 == bytes32("id") && _eq(a3, "_assetPairPrices")
                && _eq(a4, "PriceOracle")
        ) {
            slot = _slotOfSlot(
                uint256(0), _slotOfKeyOfSlot(a2, _slotOfStorage(201, a4))
            );
        }

        if (
            a1 == bytes32("price") && _eq(a3, "_assetPairPrices")
                && _eq(a4, "PriceOracle")
        ) {
            slot = _slotOfSlot(
                uint256(1), _slotOfKeyOfSlot(a2, _slotOfStorage(201, a4))
            );
        }

        if (
            a1 == bytes32("timestamp") && _eq(a3, "_assetPairPrices")
                && _eq(a4, "PriceOracle")
        ) {
            slot = _slotOfSlot(
                uint256(2), _slotOfKeyOfSlot(a2, _slotOfStorage(201, a4))
            );
        }
    }

    function _slotOf(string memory a1, string memory a2)
        internal
        pure
        returns (bytes32 slot)
    {
        if (_eq(a1, "_owner") && _eq(a2, "PriceOracle")) {
            slot = _slotOfStorage(uint256(51), a2);
        }
    }
}
