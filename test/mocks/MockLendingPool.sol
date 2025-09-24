// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../../src/interfaces/ILendingPool.sol";

contract MockLendingPool is ILendingPool {
    struct UserAccountData {
        uint256 totalCollateralETH;
        uint256 totalDebtETH;
        uint256 availableBorrowsETH;
        uint256 currentLiquidationThreshold;
        uint256 ltv;
        uint256 healthFactor;
    }

    mapping(address => UserAccountData) public userAccountData;

    function setUserAccountData(address user, uint256 totalCollateralETH, uint256 totalDebtETH, uint256 availableBorrowsETH, uint256 currentLiquidationThreshold, uint256 ltv, uint256 healthFactor) external {
        userAccountData[user] = UserAccountData(totalCollateralETH, totalDebtETH, availableBorrowsETH, currentLiquidationThreshold, ltv, healthFactor);
    }

    function repay(address /*asset*/, uint256 /*amount*/, uint256 /*rateMode*/, address /*onBehalfOf*/) external {}
    // Implement other functions as needed for testing, but they can be empty for this test
    function deposit(address /*asset*/, uint256 /*amount*/, address /*onBehalfOf*/, uint16 /*referralCode*/) external {}
    function withdraw(address /*asset*/, uint256 /*amount*/, address /*to*/) external {}
    function borrow(address /*asset*/, uint256 /*amount*/, uint256 /*interestRateMode*/, uint16 /*referralCode*/, address /*onBehalfOf*/) external {}
    function swapBorrowRateMode(address /*asset*/, uint256 /*rateMode*/) external {}
    function rebalanceStableBorrowRate(address /*asset*/, address /*user*/) external {}
    function setUserUseReserveAsCollateral(address /*asset*/, bool /*useAsCollateral*/) external {}
    function liquidationCall(address /*collateralAsset*/, address /*debtAsset*/, address /*user*/, uint256 /*debtToCover*/, bool /*receiveAToken*/) external {}
    function flashLoan(address /*receiverAddress*/, address[] calldata /*assets*/, uint256[] calldata /*amounts*/, uint256[] calldata /*modes*/, address /*onBehalfOf*/, bytes calldata /*params*/, uint16 /*referralCode*/) external {}
    
    function getUserAccountData(address user) external view override returns (uint256 totalCollateralETH, uint256 totalDebtETH, uint256 availableBorrowsETH, uint256 currentLiquidationThreshold, uint256 ltv, uint256 healthFactor) {
        UserAccountData memory data = userAccountData[user];
        return (data.totalCollateralETH, data.totalDebtETH, data.availableBorrowsETH, data.currentLiquidationThreshold, data.ltv, data.healthFactor);
    }

    function getConfiguration(address /*asset*/) external view returns (DataTypes.ReserveConfigurationMap memory) {
        DataTypes.ReserveConfigurationMap memory config;
        return config;
    }
    function getReserveData(address /*asset*/) external view returns (DataTypes.ReserveData memory) {
        DataTypes.ReserveData memory data;
        return data;
    }
    function getUserConfiguration(address /*asset*/, address /*user*/) external view returns (DataTypes.UserConfigurationMap memory) {
        DataTypes.UserConfigurationMap memory config;
        return config;
    }
    function getReserveNormalizedIncome(address /*asset*/) external view returns (uint256) {
        return 0;
    }
    function getReserveNormalizedVariableDebt(address /*asset*/) external view returns (uint256) {
        return 0;
    }
    function getReserveState(address /*asset*/) external view returns (uint128, int128, uint128, uint128, uint128, uint40) {
        return (0, 0, 0, 0, 0, 0);
    }
    function getAddressesProvider() external view returns (ILendingPoolAddressesProvider) {
        return ILendingPoolAddressesProvider(address(0));
    }
}
