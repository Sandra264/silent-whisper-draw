import { ethers } from "hardhat";

async function main() {
  console.log("Deploying FHECounter contract...");
  
  const FHECounter = await ethers.getContractFactory("FHECounter");
  const counter = await FHECounter.deploy();
  
  await counter.waitForDeployment();
  
  const address = await counter.getAddress();
  console.log(`FHECounter deployed to: ${address}`);
  
  const owner = await counter.owner();
  console.log(`Contract owner: ${owner}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

