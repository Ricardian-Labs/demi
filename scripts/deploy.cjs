const hre = require("hardhat");

async function main() {
  console.log("🚀 Deploying DEMI token...\n");
  
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying from:", deployer.address);
  
  const USDT_ADDRESS = "0xc2132D05D31c914a87C6611C10748AEb04B58e8F";
  const USDC_ADDRESS = "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174";
  
  console.log("\n⏳ Deploying contract...\n");
  
  const DEMI = await hre.ethers.getContractFactory("DEMI");
  const demi = await DEMI.deploy(USDT_ADDRESS, USDC_ADDRESS);
  await demi.waitForDeployment();
  
  const address = await demi.getAddress();
  
  console.log("\n" + "=".repeat(60));
  console.log("🎉 SUCCESS! DEMI TOKEN DEPLOYED!");
  console.log("=".repeat(60));
  console.log("\n📍 CONTRACT ADDRESS:", address);
  console.log("\n💎 TOKEN DETAILS:");
  console.log("   Total Supply: 3,300,000,000 DEMI");
  console.log("   Initial Price: $0.01 per DEMI");
  console.log("   Sale Status: ACTIVE ✅");
  console.log("\n🔗 View on PolygonScan:");
  console.log(`   https://amoy.polygonscan.com/address/${address}`);
  console.log("\n✅ DEPLOYMENT COMPLETE!\n");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
