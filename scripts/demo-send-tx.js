const { ethers } = require('ethers');
const config = require('../operator/config.json');

async function main() {
  const provider = new ethers.providers.JsonRpcProvider(config.provider);
  const signer = provider.getSigner();

  // Create a fake 'large borrow' transaction by sending > threshold ETH to configured lending pool
  const tx = await signer.sendTransaction({
    to: config.lendingPools[0] || '0x0000000000000000000000000000000000000000',
    value: ethers.utils.parseEther('200') // 200 ETH
  });

  console.log('Demo TX sent:', tx.hash);
  await tx.wait();
}

main().catch(console.error);
