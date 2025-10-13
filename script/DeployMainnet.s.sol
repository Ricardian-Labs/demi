// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../contracts/DEMI.sol";

contract DeployMainnetScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        
        // REAL Polygon Mainnet addresses
        address USDT = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F;
        address USDC = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
        
        console.log("=== DEPLOYING TO POLYGON MAINNET ===");
        console.log("USDT:", USDT);
        console.log("USDC:", USDC);
        
        vm.startBroadcast(deployerPrivateKey);
        
        DEMI demi = new DEMI(USDT, USDC);
        
        vm.stopBroadcast();
        
        console.log("\n=== DEPLOYMENT SUCCESSFUL ===");
        console.log("DEMI Token Address:", address(demi));
        console.log("Total Supply: 3,300,000,000 DEMI");
        console.log("Initial Price: $0.01 per DEMI");
        console.log("Sale Status: ACTIVE");
        console.log("\nView on PolygonScan:");
        console.log("https://polygonscan.com/address/", address(demi));
    }
}
