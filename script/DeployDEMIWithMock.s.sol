// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../contracts/DEMI.sol";

contract DeployDEMIWithMockScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        
        // Use MockUSDT and MockUSDC addresses
        address mockUSDT = 0xe02AAb68e3AD0e16b825F4Cb14cdEF60a21E10b4;
        address mockUSDC = 0xe02AAb68e3AD0e16b825F4Cb14cdEF60a21E10b4; // Using same for both
        
        vm.startBroadcast(deployerPrivateKey);
        
        DEMI demi = new DEMI(mockUSDT, mockUSDC);
        
        vm.stopBroadcast();
        
        console.log("DEMI deployed at:", address(demi));
        console.log("Using Mock USDT at:", mockUSDT);
    }
}
