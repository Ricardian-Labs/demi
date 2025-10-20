// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {DEMI} from "../contracts/DEMI.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("AMOY_PRIVATE_KEY");
        
        uint256 chainId = block.chainid;
        
        address USDT;
        address USDC;
        address COFOUNDER = 0x6254081923f1125Fa6662285b0229e4bd8Ed2c1D;
        address RELAY = address(0);  // Deploy with no relay first, update later
        string memory network;
        
        if (chainId == 137) {
            network = "Polygon Mainnet";
            USDT = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F;
            USDC = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
        } else if (chainId == 80002) {
            network = "Polygon Amoy Testnet";
            USDT = 0x7d43AABC515C356145049227CeE54B608342c0ad;
            USDC = 0x41E94Eb019C0762f9Bfcf9Fb1E58725BfB0e7582;
        } else {
            revert("Unsupported chain");
        }
        
        console.log("Deploying DEMI to:", network);
        console.log("Chain ID:", chainId);
        console.log("USDT:", USDT);
        console.log("USDC:", USDC);
        console.log("Cofounder:", COFOUNDER);
        console.log("Relay:", RELAY);
        
        vm.startBroadcast(deployerPrivateKey);
        
        DEMI demi = new DEMI(USDT, USDC, COFOUNDER, RELAY);
        
        console.log("\n=== DEMI Deployed ===");
        console.log("Contract:", address(demi));
        console.log("Owner:", demi.owner());
        console.log("Token Price:", demi.tokenPrice());
        console.log("Sale Active:", demi.saleActive());
        console.log("Cofounder Vesting:", address(demi.cofounderVesting()));
        console.log("\nNOTE: Update relay address with: demi.updateRelay(relayAddress)");
        
        vm.stopBroadcast();
    }
}
