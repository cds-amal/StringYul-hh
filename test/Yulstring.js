const {
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
//   const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("YulString", function() {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployYulString() {
    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();

    const YulString = await ethers.getContractFactory("YulString");
    console.log(Object.keys(YulString));
    const yulString = await YulString.deploy();

    return { yulString, owner, otherAccount };
  }

  describe("Deployment", function() {
    it("should handle 'hello world'", async function() {
      const { yulString } = await loadFixture(deployYulString);

      const text = "Hello World";
      await yulString.setValue(text);
      let val = await yulString.getValue();

      expect(val).to.equal(text);
    });
  });
});
