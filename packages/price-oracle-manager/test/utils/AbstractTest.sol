// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// solhint-disable-next-line no-global-import
import "forge-std/Test.sol";
import {Slots} from "test/mocks/Slots.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

abstract contract AbstractTest is Test, Slots {
    using Address for address;

    address public constant BOB = address(0xB0B);
    address public constant OBI = address(0x0B1);
    address public constant ZOE = address(0x20E);
    address public constant ADA = address(0xADA);

    bool internal _forkMode;
    address internal _owner;

    function setUp() public virtual {
        try vm.envBool("FORK_MODE") returns (bool v) {
            _forkMode = v;
            // solhint-disable-next-line no-empty-blocks
        } catch {}

        _owner = vm.envAddress("LOCAL_OWNER_ADDRESS");

        if (block.chainid == 80001) {
            _owner = vm.envAddress("POLYGON_MUMBAI_OWNER_ADDRESS");
        }

        if (block.chainid == 137) {
            _owner = vm.envAddress("POLYGON_MAINNET_OWNER_ADDRESS");
        }

        // solhint-disable-next-line reason-string
        require(_owner != address(0), "_owner must be a non-zero address");

        vm.label(_owner, "owner");
        vm.label(BOB, "BOB");
        vm.label(OBI, "OBI");
        vm.label(ZOE, "ZOE");
        vm.label(ADA, "ADA");
    }
}
