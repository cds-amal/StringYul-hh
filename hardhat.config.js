require("@nomicfoundation/hardhat-toolbox");
require("@tovarishfin/hardhat-yul");
/** @type import('hardhat/config').HardhatUserConfig */

const YulString = require("./yulstring.config");

module.exports = {
  solidity: "0.8.20",
  yulArtifacts: { YulString },
};
