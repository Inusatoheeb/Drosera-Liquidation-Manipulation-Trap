# Deployment Steps

This document outlines the deployment process for the Liquidation Manipulation Trap.

The process is separated into two main stages: deploying the response contract with Foundry, and deploying the main trap contract with the Drosera CLI.

## Stage 1: Deploy the Response Contract using Foundry

The `BaitResponse.sol` contract must be deployed to the blockchain first, as its address is required for the Drosera trap configuration.

1.  **Set Up Environment**: Ensure you have an RPC URL for the target network (e.g., Sepolia) and a private key for deployment, preferably stored as environment variables.

2.  **Run the Foundry Deployment Script**: Use the following command to deploy `BaitResponse.sol`. Replace `<YOUR_RPC_URL>` with your target network's RPC endpoint.

    ```bash
    forge script scripts/DeployBaitResponse.s.sol:DeployBaitResponse --rpc-url <YOUR_RPC_URL> --broadcast --verify
    ```
    *Adding `--verify` will attempt to verify the contract on Etherscan if you have `ETHERSCAN_API_KEY` set up in your environment.*

3.  **Capture the Deployed Address**: After the script runs, Foundry will output the address of the newly deployed `BaitResponse` contract. Copy this address for the next stage.

## Stage 2: Update `drosera.toml` and Deploy the Main Trap

Now, you will update the trap's configuration file with the address from the previous stage.

1.  **Update `response_contract`**: Open the `drosera.toml` file and replace the placeholder address in the `response_contract` field with the address of your deployed `BaitResponse` contract.

    ```toml
    # drosera.toml
    ...
    response_contract = "0x...<YOUR_DEPLOYED_BAITRESPONSE_ADDRESS>"
    ...
    ```

2.  **Deploy with Drosera CLI**: With the `drosera.toml` file updated, you can now deploy the main trap contract (`FlashBait.sol`) using the Drosera CLI. This step will register the trap with the Drosera network, using the on-chain response contract you just configured.

    *(Execute the appropriate Drosera CLI command for trap deployment here.)*

This completes the deployment process. The trap will be live and will use your deployed `BaitResponse` contract to log any suspicious activity it detects.
