// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../contracts/DEMI.sol";

contract TestBuyScript is Script {
    function run() external {
        address demiAddress = 0x9813434BD6CB87D22559D7Da13bB3D11e22D4b27;
        DEMI demi = DEMI(demiAddress);
        
        console.log("=== DEMI CONTRACT TEST ===");
        console.log("Contract Address:", address(demi));
        console.log("Your Address:", msg.sender);
        
        // Check contract details
        console.log("\n--- Token Info ---");
        console.log("Name:", demi.name());
        console.log("Symbol:", demi.symbol());
        console.log("Total Supply:", demi.totalSupply());
        console.log("Contract Balance:", demi.balanceOf(address(demi)));
        
        // Check sale info
        console.log("\n--- Sale Info ---");
        console.log("Token Price:", demi.tokenPrice());
        console.log("Sale Active:", demi.saleActive());
        console.log("Total Sold:", demi.totalSold());
        
        // Get your balance
        console.log("\n--- Your Balance ---");
        console.log("Your DEMI Balance:", demi.balanceOf(msg.sender));
    }
}
