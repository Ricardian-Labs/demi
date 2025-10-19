// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../contracts/DEMI.sol";

contract DeployMainnetScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        
        // Polygon Mainnet addresses
        address USDT = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F;
        address USDC = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
        address COFOUNDER = 0x6254081923f1125Fa6662285b0229e4bd8Ed2c1D;
        
        // Universal Relay address (deploy relay first)
        address RELAY = vm.envAddress("RELAY_ADDRESS");
        
        vm.startBroadcast(deployerPrivateKey);
        
        DEMI demi = new DEMI(USDT, USDC, COFOUNDER, RELAY);
        
        console.log("=== DEMI Mainnet Deployment ===");
        console.log("Contract:", address(demi));
        console.log("Owner:", demi.owner());
        console.log("Token Price:", demi.tokenPrice());
        console.log("Cofounder Vesting:", address(demi.cofounderVesting()));
        console.log("Relay:", demi.relay());
        
        vm.stopBroadcast();
    }
}
