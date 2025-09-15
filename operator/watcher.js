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

function looksLargeBorrow(tx) {
  try {
    const value = tx.value ? ethers.BigNumber.from(tx.value) : ethers.BigNumber.from(0);
    return value.gte(ethers.BigNumber.from(config.minBorrowAmountWei || '0'));
  } catch (e) { return false; }
}

async function processPending(txHash) {
  try {
    const tx = await provider.getTransaction(txHash);
    if (!tx || !tx.to) return;

    const to = tx.to.toLowerCase();

    // Heuristic: if to is a known lending pool, or if value/borrow large
    if (KNOWN_LENDING_POOL_ADDRESSES.map(a => a.toLowerCase()).includes(to) || looksLargeBorrow(tx)) {
      console.log(`⚠️ Suspicious pending tx: ${txHash} -> ${tx.to}`);
      const reason = `Suspicious liquidation-manip pattern: to=${tx.to}`;
      const txHashBytes = ethers.utils.hexlify(ethers.utils.randomBytes(32));
      const encoded = ethers.utils.defaultAbiCoder.encode(["bytes32","string"], [txHashBytes, reason]);

      // Call executeBytes on BaitResponse (simulate Drosera response)
      const sent = await bait.executeBytes(encoded, { gasLimit: 200000 });
      console.log('BaitResponse tx sent:', sent.hash);
    }

  } catch (err) {
    console.error('processPending error', err);
  }
}

provider.on('pending', (txHash) => {
  processPending(txHash);
});

console.log('Watcher started — listening to pending mempool...');
