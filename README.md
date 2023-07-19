# Sample Hardhat Project

This project demonstrates how to test a pure Yul contract with Hardhat. It build on the basic Hardhat use case. It comes with:
- a sample contract which simulates setting and getting a string from a contract.
- test for that contract `npx hardhat test`
- a deployment script 
`
- TypeScript (main branch) and Javascript (javascript branch)

This builds on @tovarishfin/hardhat-yul's plugin, [modified here](https://github.com/cds-amal/hardhat-yul) which
introduces a mechanism to inject the Yul's contract's ABI (See [hardhat.config.ts](./hardhat.config.ts))

Try running the following task:

```shell
npx hardhat typechain  # generate types from abi
npx hardhat test       # run tests
npx hardhat run scripts/deploy.ts --network localhost  # deploy to local network
```
