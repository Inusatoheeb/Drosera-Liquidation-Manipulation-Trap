// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/LiquidationResponder.sol";
import "./mocks/MockLendingPool.sol";
import "./mocks/MockERC20.sol";

contract LiquidationGuardTest is Test {
    LiquidationGuard public liquidationGuard;
    MockLendingPool public mockLendingPool;
    MockERC20 public mockDebtToken;
    address public user = address(0x123);
    address public authorizedCaller = address(0x456);

    function setUp() public {
        mockLendingPool = new MockLendingPool();
        mockDebtToken = new MockERC20();
        liquidationGuard = new LiquidationGuard(address(mockLendingPool), address(mockDebtToken));
        liquidationGuard.setAuthorizedCaller(authorizedCaller);
    }

    function testSetAuthorizedCaller() public {
        address newCaller = address(0x789);
        liquidationGuard.setAuthorizedCaller(newCaller);
        assertEq(liquidationGuard.authorizedCaller(), newCaller);
    }

    function testAttemptDefense_Authorized() public {
        uint256 debtToCover = 100e18;
        bytes memory data = abi.encode(address(0), user, debtToCover);

        vm.expectCall(
            address(mockDebtToken),
            abi.encodeWithSelector(
                mockDebtToken.approve.selector,
                address(mockLendingPool),
                debtToCover
            )
        );

        vm.expectCall(
            address(mockLendingPool),
            abi.encodeWithSelector(
                mockLendingPool.repay.selector,
                address(mockDebtToken),
                debtToCover,
                2,
                user
            )
        );

        vm.prank(authorizedCaller);
        liquidationGuard.executeBytes(data);
    }

    function testAttemptDefense_Unauthorized() public {
        uint256 debtToCover = 100e18;
        bytes memory data = abi.encode(address(0), user, debtToCover);

        vm.expectRevert("Not authorized");
        liquidationGuard.executeBytes(data);
    }
}
