// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

contract FlashBait is ITrap {
    function collect() external view override returns (bytes memory) {
        // This trap's logic is primarily off-chain in the watcher.
        // The collect function is a placeholder to satisfy the ITrap interface.
        return "";
    }

    function shouldRespond(
        bytes[] calldata data
    ) external pure override returns (bool, bytes memory) {
        // This trap's logic is primarily off-chain in the watcher.
        // The shouldRespond function is a placeholder to satisfy the ITrap interface.
        return (false, "");
    }
}
