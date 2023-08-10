# Untrusted Escrow

## spec

- [x] Solidity contract 4: (hard) Untrusted escrow. Create a contract where a buyer can put an arbitrary ERC20 token into a contract and a seller can withdraw it 3 days later. Based on your readings above, what issues do you need to defend against? Create the safest version of this that you can while guarding against issues that you cannot control.

Create a contract where a buyer can put an arbitrary ERC20 token into a contract and a seller can withdraw it 3 days later. Based on your readings above, what issues do you need to defend against? Create the safest version of this that you can while guarding against issues that you cannot control.

## tests

| File                     | % Lines         | % Statements    | % Branches     | % Funcs       |
| ------------------------ | --------------- | --------------- | -------------- | ------------- |
| src/Escrow.sol           | 100.00% (15/15) | 100.00% (16/16) | 85.71% (12/14) | 100.00% (2/2) |
| test/mocks/MockERC20.sol | 100.00% (1/1)   | 100.00% (1/1)   | 100.00% (0/0)  | 100.00% (1/1) |
| Total                    | 100.00% (16/16) | 100.00% (17/17) | 85.71% (12/14) | 100.00% (3/3) |
