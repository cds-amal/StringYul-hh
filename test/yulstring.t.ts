import {
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("YulString", function() {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployYulStringFixture() {
    const YulString = await ethers.getContractFactory("YulString");
    const yulString = await YulString.deploy();
    return { yulString };
  }

  describe("Deployment", function() {
    it("Should work with hello world", async function() {
      const { yulString } = await loadFixture(deployYulStringFixture);
      const text = "Hello, world!";

      await yulString.setValue(text);
      const storedText = await yulString.getValue();
      expect(storedText).to.equal(text);
    });

    [8, 15, 16, 17, 31, 32, 33, 64, 65, 515].forEach(function(len) {
      it(`should handle strlen ${len}`, async function() {
        const { yulString } = await loadFixture(deployYulStringFixture);
        const text = "0".repeat(len);
        await yulString.setValue(text);
        let val = await yulString.getValue();
        expect(val).to.equal(text);
      });
    });
  });
});
