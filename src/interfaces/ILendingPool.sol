// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.8.17;

/**
 * @title ILendingPool
 * @author Aave
 * @notice Defines the interface for the Aave Lending Pool.
 */
interface ILendingPool {
  /**
   * @dev Emitted on deposit.
   * @param reserve The address of the underlying asset of the reserve
   * @param user The address of the user who deposited
   * @param onBehalfOf The address of the user who received the aTokens
   * @param amount The amount deposited
   * @param referral The referral code
   */
  event Deposit(
    address indexed reserve,
    address user,
    address indexed onBehalfOf,
    uint256 amount,
    uint16 indexed referral
  );

  /**
   * @dev Emitted on withdrawal.
   * @param reserve The address of the underlying asset of the reserve
   * @param user The address of the user who withdrew
   * @param to The address of the user who received the underlying asset
   * @param amount The amount withdrawn
   */
  event Withdraw(address indexed reserve, address indexed user, address indexed to, uint256 amount);

  /**
   * @dev Emitted on borrow.
   * @param reserve The address of the underlying asset of the reserve
   * @param user The address of the user who borrowed
   * @param onBehalfOf The address of the user who received the borrowed assets
   * @param amount The amount borrowed
   * @param borrowRateMode The borrow rate mode: 1 for Stable, 2 for Variable
   * @param borrowRate The numeric rate at which the user has borrowed
   * @param referral The referral code
   */
  event Borrow(
    address indexed reserve,
    address user,
    address indexed onBehalfOf,
    uint256 amount,
    uint256 borrowRateMode,
    uint256 borrowRate,
    uint16 indexed referral
  );

  /**
   * @dev Emitted on repay.
   * @param reserve The address of the underlying asset of the reserve
   * @param user The address of the user who repaid
   * @param repayer The address of the user who repaid
   * @param amount The amount repaid
   */
  event Repay(
    address indexed reserve,
    address indexed user,
    address indexed repayer,
    uint256 amount
  );

  /**
   * @dev Emitted on swap of borrow rate mode.
   * @param reserve The address of the underlying asset of the reserve
   * @param user The address of the user who swapped
   * @param rateMode The new borrow rate mode: 1 for Stable, 2 for Variable
   */
  event Swap(address indexed reserve, address indexed user, uint256 rateMode);

  /**
   * @dev Emitted on user reconfiguration of reserve.
   * @param reserve The address of the underlying asset of the reserve
   * @param user The address of the user who reconfigured
   */
  event ReserveUsedAsCollateralEnabled(address indexed reserve, address indexed user);

  /**
   * @dev Emitted on user reconfiguration of reserve.
   * @param reserve The address of the underlying asset of the reserve
   * @param user The address of the user who reconfigured
   */
  event ReserveUsedAsCollateralDisabled(address indexed reserve, address indexed user);

  /**
   * @dev Emitted on flash loan.
   * @param target The address of the target of the flash loan
   * @param initiator The address of the initiator of the flash loan
   * @param asset The address of the asset of the flash loan
   * @param amount The amount of the flash loan
   * @param premium The fee of the flash loan
   * @param referralCode The referral code
   */
  event FlashLoan(
    address indexed target,
    address indexed initiator,
    address indexed asset,
    uint256 amount,
    uint256 premium,
    uint16 referralCode
  );

  /**
   * @dev Emitted when a borrow fee is liquidated.
   * @param collateralAsset The address of the collateral asset
   * @param debtAsset The address of the debt asset
   * @param user The address of the user who was liquidated
   * @param debtToCover The amount of debt liquidated
   * @param liquidatedCollateralAmount The amount of collateral liquidated
   * @param liquidator The address of the liquidator
   * @param receiveAToken `true` if the liquidators wants to receive the aToken, `false` otherwise
   */
  event LiquidationCall(
    address indexed collateralAsset,
    address indexed debtAsset,
    address indexed user,
    uint256 debtToCover,
    uint256 liquidatedCollateralAmount,
    address liquidator,
    bool receiveAToken
  );

  /**
   * @dev Emitted when the pause state is changed.
   * @param paused The new pause state
   */
  event Paused(bool paused);

  /**
   * @dev Emitted when the active state is changed.
   * @param active The new active state
   */
  event Active(bool active);

  /**
   * @dev Deposits an `amount` of underlying asset into the reserve, receiving in return overlying aTokens.
   * - E.g. User deposits 100 USDC and gets in return 100 aUSDC
   * @param asset The address of the underlying asset to deposit
   * @param amount The amount to be deposited
   * @param onBehalfOf The address that will receive the aTokens, same as msg.sender if the user
   *   wants to receive them on his own wallet, or a different address if the user wants to deposit
   *   on behalf of another wallet
   * @param referralCode Code used to register the integrator originating the operation, for potential rewards.
   *   0 if the user is not part of any integrator program.
   */
  function deposit(
    address asset,
    uint256 amount,
    address onBehalfOf,
    uint16 referralCode
  ) external;

  /**
   * @dev Withdraws an `amount` of underlying asset from the reserve, burning the equivalent aTokens owned.
   * - E.g. User has 100 aUSDC, calls withdraw() and receives 100 USDC, burning the 100 aUSDC
   * @param asset The address of the underlying asset to withdraw
   * @param amount The underlying amount to be withdrawn
   *   - Send the value type(uint256).max in order to withdraw the whole balance.
   * @param to Address that will receive the underlying asset
   */
  function withdraw(
    address asset,
    uint256 amount,
    address to
  ) external;

  /**
   * @dev Allows users to borrow a specific `amount` of the reserve underlying asset, provided that the borrower
   * already deposited enough collateral, or has enough delegated credit.
   * - E.g. User deposits 100 ETH as collateral, and borrows 1000 USDC
   * @param asset The address of the underlying asset to borrow
   * @param amount The amount to be borrowed
   * @param interestRateMode The interest rate mode at which the user wants to borrow: 1 for Stable, 2 for Variable
   * @param referralCode Code used to register the integrator originating the operation, for potential rewards.
   *   0 if the user is not part of any integrator program.
   * @param onBehalfOf Address of the user who will receive the debt. Should be the address of the borrower itself
   * calling the function if he wants to borrow against his own collateral, or the address of the delegated borrower
   * if he has credit delegated.
   */
  function borrow(
    address asset,
    uint256 amount,
    uint256 interestRateMode,
    uint16 referralCode,
    address onBehalfOf
  ) external;

  /**
   * @notice Repays a borrowed `amount` on a specific `asset`, for a specific `user`.
   * - E.g. User borrowed 1000 USDC, calls repay() with 1000 USDC and removes the debt.
   * @param asset The address of the underlying asset to repay
   * @param amount The amount to repay
   * - Send the value type(uint256).max in order to repay the whole debt for `user`
   * @param rateMode The interest rate mode at which the user borrowed: 1 for Stable, 2 for Variable
   * @param onBehalfOf Address of the user who will get his debt reduced/removed. Should be the address of the
   * user calling the function if he wants to reduce/remove his own debt, or the address of any other
   * user if he wants to repay someone else's debt.
   */
  function repay(
    address asset,
    uint256 amount,
    uint256 rateMode,
    address onBehalfOf
  ) external;

  /**
   * @dev Allows a user to swap his borrow rate mode between stable and variable.
   * @param asset The address of the underlying asset borrowed
   * @param rateMode The rate mode that the user wants to swap to
   */
  function swapBorrowRateMode(address asset, uint256 rateMode) external;

  /**
   * @dev Rebalances the stable borrow rate of a user to the current stable rate defined on the reserve.
   * - Users can use this function to force rebalance their stable rate loan even if the rebalance threshold is not reached.
   * @param asset The address of the underlying asset borrowed
   * @param user The address of the user to be rebalanced
   */
  function rebalanceStableBorrowRate(address asset, address user) external;

  /**
   * @dev Allows users to enable or disable a specific deposited asset as collateral.
   * @param asset The address of the underlying asset deposited
   * @param useAsCollateral `true` if the user wants to use the deposit as collateral, `false` otherwise
   */
  function setUserUseReserveAsCollateral(address asset, bool useAsCollateral) external;

  /**
   * @dev Function to liquidate a non-healthy position liquidator buys collateral paying with debt asset.
   * - The caller of this function is the liquidator, which buys the collateral of a user `user` with a health factor
   *   below 1.
   * @param collateralAsset The address of the collateral asset to liquidated
   * @param debtAsset The address of the debt asset to repay with
   * @param user The address of the user whose position is being liquidated
   * @param debtToCover The amount of debt that the liquidator wants to cover
   * @param receiveAToken `true` if the liquidators wants to receive the aToken, `false` otherwise
   */
  function liquidationCall(
    address collateralAsset,
    address debtAsset,
    address user,
    uint256 debtToCover,
    bool receiveAToken
  ) external;

  /**
   * @dev Allows initiator to borrow assets from the protocol and pay it back in the same transaction, plus a fee.
   * @param receiverAddress The address of the contract that will receive the funds, implementing the IFlashLoanReceiver interface
   * @param assets The addresses of the assets to flashloan
   * @param amounts The amounts of the assets to flashloan
   * @param modes Types of the debt to open if the flashloan is not returned:
   *   0 -> Don't open any debt, just revert if funds are not available
   *   1 -> Open debt at stable rate for the user
   *   2 -> Open debt at variable rate for the user
   * @param onBehalfOf The address of the user who will receive the debt in the case of using on `modes` 1 or 2
   * @param params Variadic packed params to pass to the receiver as extra information
   * @param referralCode Code used to register the integrator originating the operation, for potential rewards.
   *   0 if the user is not part of any integrator program.
   */
  function flashLoan(
    address receiverAddress,
    address[] calldata assets,
    uint256[] calldata amounts,
    uint256[] calldata modes,
    address onBehalfOf,
    bytes calldata params,
    uint16 referralCode
  ) external;

  /**
   * @dev Returns the user account data across all the reserves
   * @param user The address of the user
   * @return totalCollateralETH the total collateral in ETH of the user
   * @return totalDebtETH the total debt in ETH of the user
   * @return availableBorrowsETH the available borrows in ETH of the user
   * @return currentLiquidationThreshold the current liquidation threshold of the user
   * @return ltv the current loan to value of the user
   * @return healthFactor the current health factor of the user
   */
  function getUserAccountData(address user)
    external
    view
    returns (
      uint256 totalCollateralETH,
      uint256 totalDebtETH,
      uint256 availableBorrowsETH,
      uint256 currentLiquidationThreshold,
      uint256 ltv,
      uint256 healthFactor
    );

  /**
   * @dev Returns the configuration of the reserve
   * @param asset The address of the underlying asset of the reserve
   * @return The configuration of the reserve
   */
  function getConfiguration(address asset)
    external
    view
    returns (DataTypes.ReserveConfigurationMap memory);

  /**
   * @dev Returns the reserve data
   * @param asset The address of the underlying asset of the reserve
   * @return The reserve data
   */
  function getReserveData(address asset) external view returns (DataTypes.ReserveData memory);

  /**
   * @dev Returns the user configuration of the reserve
   * @param asset The address of the underlying asset of the reserve
   * @param user The address of the user
   * @return The user configuration of the reserve
   */
  function getUserConfiguration(address asset, address user)
    external
    view
    returns (DataTypes.UserConfigurationMap memory);

  /**
   * @dev Returns the normalized income per unit of asset
   * @param asset The address of the underlying asset of the reserve
   * @return The reserve normalized income
   */
  function getReserveNormalizedIncome(address asset) external view returns (uint256);

  /**
   * @dev Returns the normalized variable debt per unit of asset
   * @param asset The address of the underlying asset of the reserve
   * @return The reserve normalized variable debt
   */
  function getReserveNormalizedVariableDebt(address asset) external view returns (uint256);

  /**
   * @dev Returns the state of the reserve
   * @param asset The address of the underlying asset of the reserve
   * @return The state of the reserve
   */
  function getReserveState(address asset)
    external
    view
    returns (
      uint128,
      int128,
      uint128,
      uint128,
      uint128,
      uint40
    );

  /**
   * @dev Returns the addresses of the lending pool core
   * @return The address of the lending pool address provider
   */
  function getAddressesProvider() external view returns (ILendingPoolAddressesProvider);
}

library DataTypes {
  // refer to the whitepaper and protocol documentation for a deeper explanation of these concepts
  struct ReserveData {
    //stores the reserve configuration
    ReserveConfigurationMap configuration;
    //the liquidity index. Expressed in ray
    uint128 liquidityIndex;
    //variable borrow index. Expressed in ray
    uint128 variableBorrowIndex;
    //the current supply rate. Expressed in ray
    uint128 currentLiquidityRate;
    //the current variable borrow rate. Expressed in ray
    uint128 currentVariableBorrowRate;
    //the current stable borrow rate. Expressed in ray
    uint128 currentStableBorrowRate;
    uint40 lastUpdateTimestamp;
    //tokens addresses
    address aTokenAddress;
    address stableDebtTokenAddress;
    address variableDebtTokenAddress;
    //address of the interest rate strategy
    address interestRateStrategyAddress;
    //the id of the reserve. Represents the position in the list of the active reserves
    uint8 id;
  }

  struct ReserveConfigurationMap {
    //bit 0-15: LTV
    //bit 16-31: Liq. threshold
    //bit 32-47: Liq. bonus
    //bit 48-55: Decimals
    //bit 56: Reserve is active
    //bit 57: reserve is frozen
    //bit 58: borrowing is enabled
    //bit 59: stable rate borrowing enabled
    //bit 60: reserve is paused
    //bit 61-63: reserved
    uint256 data;
  }

  struct UserConfigurationMap {
    uint256 data;
  }
}

interface ILendingPoolAddressesProvider {
  event MarketIdSet(string newMarketId);
  event LendingPoolUpdated(address indexed newAddress);
  event ConfigurationAdminUpdated(address indexed newAddress);
  event EmergencyAdminUpdated(address indexed newAddress);
  event LendingPoolConfiguratorUpdated(address indexed newAddress);
  event LendingRateOracleUpdated(address indexed newAddress);
  event PriceOracleUpdated(address indexed newAddress);
  event ProxyCreated(bytes32 id, address indexed newAddress);
  event AddressSet(bytes32 id, address indexed newAddress, bool hasProxy);

  function getMarketId() external view returns (string memory);

  function setMarketId(string calldata marketId) external;

  function getAddress(bytes32 id) external view returns (address);

  function setAddress(bytes32 id, address newAddress) external;

  function setAddressAsProxy(
    bytes32 id,
    address impl,
    bytes calldata params
  ) external;

  function getLendingPool() external view returns (address);

  function setLendingPoolImpl(address pool) external;

  function getLendingPoolConfigurator() external view returns (address);

  function setLendingPoolConfiguratorImpl(address configurator) external;

  function getPriceOracle() external view returns (address);

  function setPriceOracle(address priceOracle) external;

  function getLendingRateOracle() external view returns (address);

  function setLendingRateOracle(address lendingRateOracle) external;

  function getEmergencyAdmin() external view returns (address);

  function setEmergencyAdmin(address admin) external;

  function getConfigurationAdmin() external view returns (address);

  function setConfigurationAdmin(address admin) external;
}
