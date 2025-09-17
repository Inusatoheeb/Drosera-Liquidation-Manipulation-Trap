// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/LiquidationGuard.sol";
import "../src/FlashBait.sol";
import "./mocks/MockLendingPool.sol";
import "./mocks/MockERC20.sol";

contract BaitTest is Test {
    LiquidationGuard public liquidationGuard;
    FlashBait public flashBait;
    MockLendingPool public mockLendingPool;
    MockERC20 public mockDebtToken;

    function setUp() public {
        mockLendingPool = new MockLendingPool();
        mockDebtToken = new MockERC20();
        liquidationGuard = new LiquidationGuard(address(mockLendingPool), address(mockDebtToken));
        flashBait = new FlashBait();
    }

    function testOwner() public {
        assertEq(liquidationGuard.owner(), address(this));
    }

    function testSetOwner() public {
        address newOwner = address(0x123);
        liquidationGuard.setOwner(newOwner);
        assertEq(liquidationGuard.owner(), newOwner);
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
