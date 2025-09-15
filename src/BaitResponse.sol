// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract BaitResponse {
    address public owner;

    event FlashCaught(address indexed reporter, bytes32 indexed txHash, string reason, uint256 timestamp);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Generic entrypoint Drosera expects: accepts bytes and acts on them.
    // For PoC we'll decode: (bytes32 txHash, string reason)
    function executeBytes(bytes calldata data) external {
        // Expected encoding: abi.encode(txHash, reason)
        (bytes32 txHash, string memory reason) = abi.decode(data, (bytes32, string));
        emit FlashCaught(msg.sender, txHash, reason, block.timestamp);
    }

    // Administrative helper
    function setOwner(address _owner) external onlyOwner {
        owner = _owner;
    }
}
