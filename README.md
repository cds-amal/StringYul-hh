# Sample Hardhat Project

This project demonstrates how to test a pure Yul contract with Hardhat. It build on the basic Hardhat use case. It comes with:
- a sample contract which simulates setting and getting a string from a contract.
- test for that contract

This builds on @tovarishfin/hardhat-yul's plugin, [modified here](https://github.com/cds-amal/hardhat-yul/tree/add-deploy) which
introduces a mechanism to inject the Yul's contract's ABI (See [hardhat.config.js](./hardhat.config.js))

Try running the following task:

```shell
npx hardhat test
```


TODO: Figure out how to deploy w/ scripts
