# Drosera — Liquidation Manipulation Trap (PoC)

Hello! I've set up this proof-of-concept to demonstrate a Drosera trap that detects **liquidation manipulation** attempts in the mempool and records them on-chain. The goal is to create a minimal, demo-ready project that clearly shows the core idea: mempool watcher -> detection -> encoded bytes -> on-chain record.

### How It Works

The system has two main parts: an off-chain operator and an on-chain response contract.

1.  **Off-Chain Operator (`operator/watcher.js`)**: This Node.js script connects to an Ethereum node, watches the mempool for pending transactions, and runs a simple heuristic. It looks for transactions sent to known lending pools or transactions involving a large amount of ETH, which could be part of a liquidation or flash loan manipulation.
2.  **On-Chain Response (`src/BaitResponse.sol`)**: When the watcher flags a suspicious transaction, it encodes details about it (a transaction hash and a reason string) into a `bytes` payload. It then calls the `executeBytes(bytes)` function on the `BaitResponse` contract. This contract decodes the data and emits a `FlashCaught` event, creating an immutable, on-chain log of the suspicious activity.

The `FlashBait.sol` contract is included to satisfy the Drosera `ITrap` interface, but for this PoC, all the detection logic lives in the off-chain watcher to keep things simple and focused on the response mechanism.

### What's Included
- `src/BaitResponse.sol`: The response contract that decodes bytes and emits an event.
- `src/FlashBait.sol`: The on-chain contract that fulfills the `ITrap` interface.
- `operator/watcher.js`: The mempool watcher that encodes the payload and calls `executeBytes(bytes)`.
- `scripts/demo-send-tx.js`: A script to simulate a malicious transaction locally.
- `drosera.toml`: The manifest for Drosera, configured for this trap.
- `test/Bait.t.sol`: Foundry test file for the contracts.

### Tech Stack
- Solidity ^0.8.17
- Foundry
- Node.js + ethers.js

---

## Quickstart (Local Fork + Demo)

1.  **Install dependencies**

    ```bash
    # Install Foundry
    curl -L https://foundry.paradigm.xyz | bash
    foundryup

    # Install Node.js dependencies
    npm init -y
    npm i ethers dotenv
    ```

2.  **Deploy `BaitResponse.sol`**

    You'll need an RPC URL for a testnet or local fork.

    ```bash
    forge script scripts/DeployBaitResponse.s.sol:DeployBaitResponse --rpc-url <YOUR_RPC_URL> --broadcast
    ```

3.  **Configure the Operator**

    Copy the deployed `BaitResponse` contract address and paste it into `operator/config.json`. You should also add your private key to send the response transaction (use a burner key).

    ```json
    {
      "provider": "http://127.0.0.1:8545",
      "baitResponseAddress": "YOUR_DEPLOYED_BAIT_RESPONSE_ADDRESS",
      "operatorPrivateKey": "YOUR_BURNER_PRIVATE_KEY",
      ...
    }
    ```

4.  **Run the Watcher**

    This will start monitoring the mempool of the network specified by your provider.

    ```bash
    node operator/watcher.js
    ```

5.  **Simulate a Malicious Transaction**

    In a separate terminal, run the demo script. This will send a large ETH transaction to a placeholder address, which the watcher will detect.

    ```bash
    node scripts/demo-send-tx.js
    ```

6.  **Observe the Results**

    You will see the watcher log the suspicious transaction and send a new transaction to the `BaitResponse` contract. You can then look up that transaction hash on a block explorer to see the `FlashCaught` event.