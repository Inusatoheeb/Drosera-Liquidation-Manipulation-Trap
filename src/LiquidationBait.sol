// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";
import {ILendingPool} from "./interfaces/ILendingPool.sol";

contract LiquidationBait is ITrap {
    address public owner;
    ILendingPool public lendingPool;
    address public collateral;
    address public userToMonitor;

    uint256 public constant HEALTH_FACTOR_THRESHOLD = 1e18; // Health factor below 1.0

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address _lendingPool, address _collateral, address _userToMonitor) {
        owner = msg.sender;
        lendingPool = ILendingPool(_lendingPool);
        collateral = _collateral;
        userToMonitor = _userToMonitor;
    }

    function setTarget(address _userToMonitor) external onlyOwner {
        userToMonitor = _userToMonitor;
    }

    function collect() external view override returns (bytes memory) {
        // Collect the user's account data from the lending pool.
        (, uint256 totalDebtETH, , , , uint256 healthFactor) =
            lendingPool.getUserAccountData(userToMonitor);

        // Return the encoded health factor, total debt, and state.
        return abi.encode(healthFactor, totalDebtETH, collateral, userToMonitor);
    }

    function shouldRespond(
        bytes[] calldata data
    ) external pure override returns (bool, bytes memory) {
        if (data.length == 0) {
            return (false, "");
        }

        // Decode the health factor and total debt from the last collect() call.
        (uint256 healthFactor, uint256 totalDebtETH, address col, address user) =
            abi.decode(data[data.length - 1], (uint256, uint256, address, address));

        // If the health factor is below the threshold, respond.
        if (healthFactor < HEALTH_FACTOR_THRESHOLD) {
            // Prepare the payload for the LiquidationGuard.
            bytes memory payload = abi.encode(
                col,
                user,
                totalDebtETH
            );
            return (true, payload);
        }

        return (false, "");
    }
}
