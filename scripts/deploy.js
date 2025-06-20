const { ethers } = require("hardhat");

async function main() {
  console.log("Deploying CollectiveMemoryPalace contract to Core Blockchain...");

  // Get the ContractFactory and Signers here
  const [deployer] = await ethers.getSigners();
  
  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());

  // Deploy the CollectiveMemoryPalace contract
  const CollectiveMemoryPalace = await ethers.getContractFactory("CollectiveMemoryPalace");
  const collectiveMemoryPalace = await CollectiveMemoryPalace.deploy();

  await collectiveMemoryPalace.deployed();

  console.log("CollectiveMemoryPalace deployed to:", collectiveMemoryPalace.address);
  console.log("Transaction hash:", collectiveMemoryPalace.deployTransaction.hash);
  
  // Wait for a few block confirmations
  console.log("Waiting for block confirmations...");
  await collectiveMemoryPalace.deployTransaction.wait(5);
  
  console.log("Contract deployed and confirmed!");
  
  // Display contract details
  console.log("\n--- Contract Details ---");
  console.log("Contract Address:", collectiveMemoryPalace.address);
  console.log("Network: Core Testnet");
  console.log("Chain ID: 1114");
  console.log("Deployer Address:", deployer.address);
  console.log("Block Number:", await ethers.provider.getBlockNumber());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Error during deployment:", error);
    process.exit(1);
  });
