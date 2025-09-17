// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/interfaces/IERC20.sol";
import "./interfaces/ILendingPool.sol";

contract LiquidationGuard {
    address public owner;
    ILendingPool public lendingPool;
    IERC20 public debtToken;

    event DefenseAttempted(
        address indexed reporter,
        address indexed collateral,
        address indexed user,
        uint256 debtToCover,
        uint256 timestamp
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address _lendingPool, address _debtToken) {
        owner = msg.sender;
        lendingPool = ILendingPool(_lendingPool);
        debtToken = IERC20(_debtToken);
    }

    // Generic entrypoint Drosera expects: accepts bytes and acts on them.
    function executeBytes(bytes calldata data) external {
        (address collateral, address user, uint256 debtToCover) = abi.decode(
            data,
            (address, address, uint256)
        );

        _attemptDefense(collateral, user, debtToCover);
    }

    function _attemptDefense(
        address collateral,
        address user,
        uint256 debtToCover
    ) internal {
        emit DefenseAttempted(
            msg.sender,
            collateral,
            user,
            debtToCover,
            block.timestamp
        );
        // In a real implementation, this function would contain logic
        // to mitigate the attack, e.g., by approving the lending pool
        // to spend our tokens and then calling the repay function.
        //
        debtToken.approve(address(lendingPool), debtToCover);
        lendingPool.repay(address(debtToken), debtToCover, 2, user);
    }

    // Administrative helper
    function setOwner(address _owner) external onlyOwner {
        owner = _owner;
    }
}
