// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

contract Escrow {
    struct Deposit {
        uint256 amount;
        uint256 block;
    }

    // tokenAddress => depositer => recipient => (amount, timestamp)
    mapping(address => mapping(address => mapping(address => Deposit))) public deposits;

    function depositTokens(address tokenAddress, address recipient, uint256 amount) external {
        // is this check too gas intensive to be worth while?
        uint256 allowance = IERC20(tokenAddress).allowance(msg.sender, address(this));
        require(allowance >= amount, "Insufficient allowance");

        // transfer tokens to this contract
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
        Deposit memory d = deposits[tokenAddress][msg.sender][recipient];

        if (d.block == 0) {
            // if this is the first deposit then set initial deposit struct
            deposits[tokenAddress][msg.sender][recipient] = Deposit(amount, block.number);
        } else {
            // otherwise update existing deposit
            deposits[tokenAddress][msg.sender][recipient].amount += amount;
            deposits[tokenAddress][msg.sender][recipient].block = block.number;
        }
    }

    function withdrawTokens(address tokenAddress, address depositer, uint256 amount) external {
        Deposit memory d = deposits[tokenAddress][depositer][msg.sender];

        require(block.number - d.block >= 21600, "Must wait 3 days");
        require(amount <= d.amount, "Insufficient funds");
        // worth the gas to check this? or simply attempt to transfer?
        require(IERC20(tokenAddress).balanceOf(address(this)) >= amount, "Insufficient balance");
        // adjust deposit to reflect funds taken out
        deposits[tokenAddress][depositer][msg.sender].amount -= amount;

        if (deposits[tokenAddress][depositer][msg.sender].amount == 0) {
            // if no funds left then remove deposit
            delete deposits[tokenAddress][depositer][msg.sender];
        }

        // call the token contract and transfer tokens to the withdrawer
        // calling this last to prevent re-entrancy
        IERC20(tokenAddress).transfer(msg.sender, amount);
    }
}
