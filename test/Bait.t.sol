// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/BaitResponse.sol";
import "../src/FlashBait.sol";

contract BaitTest is Test {
    BaitResponse public baitResponse;
    FlashBait public flashBait;

    function setUp() public {
        baitResponse = new BaitResponse();
        flashBait = new FlashBait();
    }

    function testOwner() public {
        assertEq(baitResponse.owner(), address(this));
    }

    function testSetOwner() public {
        address newOwner = address(0x123);
        baitResponse.setOwner(newOwner);
        assertEq(baitResponse.owner(), newOwner);
    }

    function testExecuteBytes() public {
        bytes32 txHash = keccak256("test tx");
        string memory reason = "test reason";
        bytes memory data = abi.encode(txHash, reason);

        vm.expectEmit(true, true, true, true);
        emit BaitResponse.FlashCaught(address(this), txHash, reason, block.timestamp);
        baitResponse.executeBytes(data);
    }

    function testFlashBaitNoLogic() public {
        // Test that the placeholder functions can be called without reverting
        bytes memory collectData = flashBait.collect();
        assertTrue(collectData.length == 0);

        bytes[] memory data;
        (bool should, bytes memory response) = flashBait.shouldRespond(data);
        assertTrue(!should);
        assertTrue(response.length == 0);
    }
}
