// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../contracts/DEMI.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        
        address USDT = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F;
        address USDC = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
        
        vm.startBroadcast(deployerPrivateKey);
        
        DEMI demi = new DEMI(USDT, USDC);
        
        vm.stopBroadcast();
        
        console.log("DEMI deployed at:", address(demi));
    }
}
