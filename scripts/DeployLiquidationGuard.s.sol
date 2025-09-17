// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "./../src/LiquidationGuard.sol";

contract DeployLiquidationGuard is Script {
    function run(address _lendingPool, address _debtToken) external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        new LiquidationGuard(_lendingPool, _debtToken);
        vm.stopBroadcast();
    }
}
