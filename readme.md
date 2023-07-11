# Solidity contract 4: Untrusted escrow

## spec

Create a contract where a buyer can put an arbitrary ERC20 token into a contract and a seller can withdraw it 3 days later. Based on your readings above, what issues do you need to defend against? Create the safest version of this that you can while guarding against issues that you cannot control.

## ideas

allow Alice to transfer tokens to the contract along with address of Bob, and also record block number or timestamp. `withdraw` function checks enough blocks have passed and that msg.sender is Bob's address.