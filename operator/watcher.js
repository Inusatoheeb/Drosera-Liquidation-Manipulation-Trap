const { ethers } = require('ethers');
const fs = require('fs');
const config = require('./config.json');
require('dotenv').config();

const provider = new ethers.providers.JsonRpcProvider(config.provider);
const operatorKey = config.operatorPrivateKey;
const signer = new ethers.Wallet(operatorKey, provider);

const baitAbi = ["function executeBytes(bytes calldata data) external"];
const bait = new ethers.Contract(config.baitResponseAddress, baitAbi, signer);

// Simple selectors / patterns to watch for: replace with real selectors and ABIs in prod
const KNOWN_LENDING_POOL_ADDRESSES = config.lendingPools || [];

// Hypothetical ABI for a lending pool contract
const lendingPoolAbi = [
  "function liquidate(address collateral, address user, uint256 debtToCover)",
  "function getUserAccountData(address user) view returns (uint256 totalCollateralETH, uint256 totalDebtETH, uint256 availableBorrowsETH, uint256 currentLiquidationThreshold, uint256 ltv, uint256 healthFactor)"
];
const lendingPoolInterface = new ethers.utils.Interface(lendingPoolAbi);

async function processPending(txHash) {
  try {
    const tx = await provider.getTransaction(txHash);
    if (!tx || !tx.to || !tx.data || tx.data === '0x') return;

    const to = tx.to.toLowerCase();

    // Heuristic: check if the transaction is to a known lending pool
    if (KNOWN_LENDING_POOL_ADDRESSES.map(a => a.toLowerCase()).includes(to)) {
      
      // Try to parse the transaction data as a liquidate call
      let decodedData;
      try {
        decodedData = lendingPoolInterface.parseTransaction({ data: tx.data, value: tx.value });
      } catch (e) {
        // Not a liquidate call, ignore
        return;
      }

      if (decodedData && decodedData.name === 'liquidate') {
        console.log(`⚠️ Suspicious liquidation pending tx: ${txHash}`);
        const { collateral, user, debtToCover } = decodedData.args;
        console.log(` -> Liquidating ${user} on collateral ${collateral} for ${debtToCover.toString()} wei`);

        try {
          console.log('Simulating transaction...');
          await provider.call(tx);
          console.log('Simulation successful.');

          // Get user account data to determine the exact debt to repay
          const lendingPool = new ethers.Contract(to, lendingPoolAbi, provider);
          const { totalDebtETH } = await lendingPool.getUserAccountData(user);

          // Encode the data for the BaitResponse contract
          const encoded = ethers.utils.defaultAbiCoder.encode(
            ["address", "address", "uint256"],
            [collateral, user, totalDebtETH]
          );
    
          // Call executeBytes on BaitResponse (simulate Drosera response)
          const sent = await bait.executeBytes(encoded, { gasLimit: 300000 });
          console.log('BaitResponse tx sent:', sent.hash);

        } catch (simulationError) {
          console.error('Transaction simulation failed:', simulationError.message);
        }
      }
    }
  } catch (err) {
    // Suppress errors like 'transaction not found', which are common with pending txs
    if (err.code !== 'NOT_FOUND') {
      console.error(`processPending error for tx ${txHash}:`, err.message);
    }
  }
}

provider.on('pending', (txHash) => {
  processPending(txHash);
});

console.log('Watcher started — listening to pending mempool...');
