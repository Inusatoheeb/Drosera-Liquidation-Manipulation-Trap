// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/interfaces/IERC20.sol";

contract MockERC20 is IERC20 {
    function name() external view returns (string memory) { return "Mock Token"; }
    function symbol() external view returns (string memory) { return "MTKN"; }
    function decimals() external view returns (uint8) { return 18; }

    function approve(address /*spender*/, uint256 /*amount*/) external returns (bool) {
        return true;
    }
    // Implement other functions as needed for testing, but they can be empty for this test
    function transfer(address /*to*/, uint256 /*amount*/) external returns (bool) { return true; }
    function transferFrom(address /*from*/, address /*to*/, uint256 /*amount*/) external returns (bool) { return true; }
    function totalSupply() external view returns (uint256) { return 0; }
    function balanceOf(address /*account*/) external view returns (uint256) { return 0; }
    function allowance(address /*owner*/, address /*spender*/) external view returns (uint256) { return 0; }
}
