import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@tovarishfin/hardhat-yul";
import YulString from "./yulstring.abi";

const config: HardhatUserConfig = {
  solidity: "0.8.20",
  yulArtifacts: { YulString },
};

export default config;
