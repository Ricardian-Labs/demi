// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../contracts/DEMI.sol";
import "../contracts/MockUSDT.sol";

contract BuyDEMIScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        
        address demiAddress = 0x9813434BD6CB87D22559D7Da13bB3D11e22D4b27;
        address usdtAddress = 0xe02AAb68e3AD0e16b825F4Cb14cdEF60a21E10b4;
        
        DEMI demi = DEMI(demiAddress);
        MockUSDT usdt = MockUSDT(usdtAddress);
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Buy 100 USDT worth of DEMI (should get 10,000 DEMI at $0.01 each)
        uint256 buyAmount = 100 * 10**6; // 100 USDT (6 decimals)
        
        console.log("=== BUYING DEMI TOKENS ===");
        console.log("Your USDT Balance:", usdt.balanceOf(msg.sender));
        console.log("Buying with:", buyAmount, "USDT");
        
        // Approve DEMI contract to spend USDT
        usdt.approve(demiAddress, buyAmount);
        console.log("Approved DEMI contract to spend USDT");
        
        // Buy DEMI
        demi.buyWithUSDT(buyAmount);
        console.log("Purchase complete!");
        
        // Check balances
        console.log("\n=== AFTER PURCHASE ===");
        console.log("Your DEMI Balance:", demi.balanceOf(msg.sender));
        console.log("Your USDT Balance:", usdt.balanceOf(msg.sender));
        console.log("Contract USDT Balance:", usdt.balanceOf(demiAddress));
        console.log("Total DEMI Sold:", demi.totalSold());
        
        vm.stopBroadcast();
    }
}
