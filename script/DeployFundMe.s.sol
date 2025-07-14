// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract DeployFundMe is Script {
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_ANSWER = 2000e8; // Simulate $2000 ETH/USD

    address public constant SEPOLIA_ETH_USD_FEED = 0x694AA1769357215DE4FAC081bf1f309aDC325306;

    function run() external returns (FundMe) {
        vm.startBroadcast();

        address priceFeed;
        if (block.chainid == 11155111) {
            // Sepolia testnet
            priceFeed = SEPOLIA_ETH_USD_FEED;
        } else {
            // Local Anvil/Hardhat chain - deploy mock
            MockV3Aggregator mock = new MockV3Aggregator(DECIMALS, INITIAL_ANSWER);
            priceFeed = address(mock);
        }

        FundMe fundMe = new FundMe(priceFeed);

        vm.stopBroadcast();
        return fundMe;
    }
}

