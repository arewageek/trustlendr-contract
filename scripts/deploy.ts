import { ethers } from "hardhat";
import { TrustLendr } from "../typechain-types/contracts";
import { Signer } from "ethers";

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const TrustLendrFactory = await ethers.getContractFactory("TrustLendr");
  const trustLendr: TrustLendr = await TrustLendrFactory.deploy(''); // Replace with the actual token address

  console.log("TrustLendr address:", trustLendr);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
