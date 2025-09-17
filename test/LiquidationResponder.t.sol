// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/LiquidationGuard.sol";

contract LiquidationGuardTest is Test {
    LiquidationGuard public liquidationGuard;
    MockLendingPool public mockLendingPool;
    MockERC20 public mockDebtToken;
    address public user = address(0x123);

    function setUp() public {
        mockLendingPool = new MockLendingPool();
        mockDebtToken = new MockERC20();
        liquidationGuard = new LiquidationGuard(address(mockLendingPool), address(mockDebtToken));
    }

    function testAttemptDefense() public {
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

        liquidationGuard.executeBytes(data);
    }
}
