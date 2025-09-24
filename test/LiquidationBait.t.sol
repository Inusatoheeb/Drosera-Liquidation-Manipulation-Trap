// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/LiquidationResponder.sol";
import "../src/LiquidationBait.sol";
import "./mocks/MockLendingPool.sol";
import "./mocks/MockERC20.sol";

contract BaitTest is Test {
    LiquidationBait public liquidationBait;
    MockLendingPool public mockLendingPool;
    address public userToMonitor = address(0xABC);
    address public collateral = address(0xDEF);

    function setUp() public {
        mockLendingPool = new MockLendingPool();
        liquidationBait = new LiquidationBait(address(mockLendingPool), collateral, userToMonitor);
    }

    function testSetTarget() public {
        address newUser = address(0x123);
        liquidationBait.setTarget(newUser);
        assertEq(liquidationBait.userToMonitor(), newUser);
    }

    function testCollect() public {
        uint256 expectedHealthFactor = 1.5e18;
        uint256 expectedDebt = 50e18;
        mockLendingPool.setUserAccountData(userToMonitor, 0, expectedDebt, 0, 0, 0, expectedHealthFactor);

        bytes memory data = liquidationBait.collect();
        (uint256 healthFactor, uint256 totalDebtETH, address col, address user) = abi.decode(data, (uint256, uint256, address, address));

        assertEq(healthFactor, expectedHealthFactor);
        assertEq(totalDebtETH, expectedDebt);
        assertEq(col, collateral);
        assertEq(user, userToMonitor);
    }

    function testShouldRespond_true() public {
        uint256 healthFactor = 0.9e18; // Below threshold
        uint256 debt = 100e18;
        bytes memory collectedData = abi.encode(healthFactor, debt, collateral, userToMonitor);
        bytes[] memory data = new bytes[](1);
        data[0] = collectedData;

        (bool should, bytes memory response) = liquidationBait.shouldRespond(data);

        assertTrue(should);

        (address respCollateral, address respUser, uint256 respDebt) = abi.decode(response, (address, address, uint256));
        assertEq(respCollateral, collateral);
        assertEq(respUser, userToMonitor);
        assertEq(respDebt, debt);
    }

    function testShouldRespond_false() public {
        uint256 healthFactor = 1.1e18; // Above threshold
        uint256 debt = 100e18;
        bytes memory collectedData = abi.encode(healthFactor, debt, collateral, userToMonitor);
        bytes[] memory data = new bytes[](1);
        data[0] = collectedData;

        (bool should, bytes memory response) = liquidationBait.shouldRespond(data);

        assertTrue(!should);
        assertTrue(response.length == 0);
    }
}
