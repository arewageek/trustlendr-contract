import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

import * as dotenv from 'dotenv'

dotenv.config();

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  typechain: {
    outDir: "typechain",
  },
  networks: {
    hardhat: {},
    sepolia: {
      url: process.env.INFURA,
      accounts: [`${process.env.PRIVATE_KEY}`]
    }
  }
};
export default config;
