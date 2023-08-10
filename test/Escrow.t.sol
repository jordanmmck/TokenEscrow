// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import "forge-std/Test.sol";
import "../src/Escrow.sol";
import "./mocks/MockERC20.sol";

contract EscrowTest is Test {
    Escrow public escrow;
    MockERC20 public mockToken;

    address public alice = address(0x1);
    address public bob = address(0x2);
    address public charlie = address(0x3);

    function setUp() public {
        escrow = new Escrow();
        mockToken = new MockERC20();
    }

    function testDepositTokens() public {
        mockToken.mint(alice, 10000e18);
        vm.prank(alice);
        mockToken.approve(address(escrow), 1e18);

        vm.prank(alice);
        escrow.depositTokens(address(mockToken), bob, 1e18);
        assertEq(mockToken.balanceOf(address(escrow)), 1e18);

        (uint256 amount, uint256 blockNum) = escrow.deposits(address(mockToken), alice, bob);
        assertEq(amount, 1e18);
        assertEq(blockNum, 1);
    }

    function testDepositTokensInsufficientAllowance() public {
        mockToken.mint(alice, 10000e18);
        vm.prank(alice);
        mockToken.approve(address(escrow), 0.5e18);

        vm.expectRevert();
        vm.prank(alice);
        escrow.depositTokens(address(mockToken), bob, 1e18);
    }

    function testDepositTokensMultipleDeposits() public {
        mockToken.mint(alice, 10000e18);
        vm.prank(alice);
        mockToken.approve(address(escrow), 1e18);

        vm.prank(alice);
        escrow.depositTokens(address(mockToken), bob, 1e18);

        mockToken.mint(alice, 10000e18);
        vm.prank(alice);
        mockToken.approve(address(escrow), 1e18);

        vm.prank(alice);
        escrow.depositTokens(address(mockToken), bob, 1e18);
    }

    function testWithdrawTokensSuccess() public {
        mockToken.mint(alice, 10000e18);
        assertEq(mockToken.balanceOf(address(alice)), 10000e18);
        vm.prank(alice);
        mockToken.approve(address(escrow), 1e18);

        vm.roll(1);
        vm.prank(alice);
        escrow.depositTokens(address(mockToken), bob, 1e18);
        assertEq(mockToken.balanceOf(address(alice)), 9999e18);
        assertEq(mockToken.balanceOf(address(bob)), 0);

        vm.roll(1 + 21600);
        vm.prank(bob);
        escrow.withdrawTokens(address(mockToken), alice, 1e18);
        assertEq(mockToken.balanceOf(address(bob)), 1e18);

        // check that entry has been deleted
        (uint256 amount, uint256 blockNum) = escrow.deposits(address(mockToken), alice, bob);
        assertEq(amount, 0);
        assertEq(blockNum, 0);
    }

    function testWithdrawTokensMustWait() public {
        mockToken.mint(alice, 10000e18);
        vm.prank(alice);
        mockToken.approve(address(escrow), 1e18);

        vm.roll(1);
        vm.prank(alice);
        escrow.depositTokens(address(mockToken), bob, 1e18);

        vm.roll(1 + 21600 - 1);
        vm.expectRevert();
        vm.prank(bob);
        escrow.withdrawTokens(address(mockToken), alice, 1e18);
    }

    function testPartialWithdraw() public {
        mockToken.mint(alice, 10000e18);
        vm.prank(alice);
        mockToken.approve(address(escrow), 1e18);

        vm.roll(1);
        vm.prank(alice);
        escrow.depositTokens(address(mockToken), bob, 1e18);

        vm.roll(1 + 21600);
        vm.prank(bob);
        escrow.withdrawTokens(address(mockToken), alice, 0.5e18);

        // check that entry has been deleted
        (uint256 amount, uint256 blockNum) = escrow.deposits(address(mockToken), alice, bob);
        assertEq(amount, 0.5e18);
        assertEq(blockNum, 1);
    }

    function testWithdrawInsufficientFunds() public {
        mockToken.mint(alice, 10000e18);
        vm.prank(alice);
        mockToken.approve(address(escrow), 1e18);

        vm.roll(1);
        vm.prank(alice);
        escrow.depositTokens(address(mockToken), bob, 1e18);

        vm.roll(1 + 21600);
        vm.prank(bob);
        vm.expectRevert("Insufficient funds");
        escrow.withdrawTokens(address(mockToken), alice, 1.5e18);
    }

    function testWithdrawInsufficientTokens() public {
        mockToken.mint(alice, 10000e18);
        vm.prank(alice);
        mockToken.approve(address(escrow), 1e18);

        vm.roll(1);
        vm.prank(alice);
        escrow.depositTokens(address(mockToken), bob, 1e18);

        // contract spends tokens!
        uint256 bal = mockToken.balanceOf(address(escrow));
        vm.prank(address(escrow));
        mockToken.transfer(address(0x99), bal);

        vm.roll(1 + 21600);
        vm.prank(bob);
        vm.expectRevert();
        escrow.withdrawTokens(address(mockToken), alice, 1e18);
    }

    function testWithdrawTokensMustApprove() public {
        mockToken.mint(alice, 10000e18);
        vm.prank(alice);

        vm.roll(1);
        vm.expectRevert();
        vm.prank(alice);
        escrow.depositTokens(address(mockToken), bob, 1e18);
    }
}
