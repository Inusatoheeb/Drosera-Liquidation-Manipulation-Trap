// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "./../src/BaitResponse.sol";

contract DeployBaitResponse is Script {
    function run() external {
        vm.startBroadcast();
        new BaitResponse();
        vm.stopBroadcast();
    }
}
