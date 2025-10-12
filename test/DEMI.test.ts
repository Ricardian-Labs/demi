import { loadFixture } from "@nomicfoundation/hardhat-toolbox-viem/network-helpers";
import { expect } from "chai";
import hre from "hardhat";
import { parseUnits } from "viem";

describe("DEMI Token", function () {
  async function deployDEMIFixture() {
    const [owner, buyer] = await hre.viem.getWalletClients();
    
    // Mock USDT and USDC addresses (for testing)
    const mockUSDT = "0xc2132D05D31c914a87C6611C10748AEb04B58e8F";
    const mockUSDC = "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174";
    
    const demi = await hre.viem.deployContract("DEMI", [mockUSDT, mockUSDC]);
    
    return { demi, owner, buyer };
  }

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      const { demi, owner } = await loadFixture(deployDEMIFixture);
      expect(await demi.read.owner()).to.equal(owner.account.address);
    });

    it("Should mint 3.3 billion tokens to contract", async function () {
      const { demi } = await loadFixture(deployDEMIFixture);
      const totalSupply = await demi.read.totalSupply();
      const contractBalance = await demi.read.balanceOf([demi.address]);
      
      expect(totalSupply).to.equal(parseUnits("3300000000", 18));
      expect(contractBalance).to.equal(totalSupply);
    });

    it("Should have correct initial price", async function () {
      const { demi } = await loadFixture(deployDEMIFixture);
      const price = await demi.read.tokenPrice();
      
      expect(price).to.equal(10000n);
    });

    it("Should have sale active by default", async function () {
      const { demi } = await loadFixture(deployDEMIFixture);
      const isActive = await demi.read.saleActive();
      
      expect(isActive).to.equal(true);
    });
  });
});
