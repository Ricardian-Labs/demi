import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const DEMIModule = buildModule("DEMIModule", (m) => {
  const usdtAddress = "0xc2132D05D31c914a87C6611C10748AEb04B58e8F";
  const usdcAddress = "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174";

  const demi = m.contract("DEMI", [usdtAddress, usdcAddress]);

  return { demi };
});

export default DEMIModule;
