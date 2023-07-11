// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Escrow.sol";

contract EscrowTest is Test {
    Escrow public escrow;

    function setUp() public {
        escrow = new Escrow();
        escrow.setNumber(0);
    }

    function testIncrement() public {
        escrow.increment();
        assertEq(escrow.number(), 1);
    }

    function testSetNumber(uint256 x) public {
        escrow.setNumber(x);
        assertEq(escrow.number(), x);
    }
}
