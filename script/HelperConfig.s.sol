// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// we use this script to store addresses of the price feeds
// if we on sepolia eth/usd price feed address - 0x694AA1769357215DE4FAC081bf1f309aDC325306

import {Script} from 'forge-std/Script.sol';
import {MockV3Aggregator} from '../test/mocks/MockV3Aggregator.sol'; // Importing the mock aggregator

contract HelperConfig is Script {
    // if we on local chain anvil we use, mock price feed address
    // or we grab existing address from live network

    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8; // 8 decimals for the price feed
    int256 public constant INITIAL_ANSWER = 2000e8; // 2000 USD in 8 decimals


    struct NetworkConfig{
        address priceFeed; // address of the price feed
        // more stuff can be added here in the future
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        // what this is going to have
        // price feed address
        // more stuff, so we make a struct for this STUFF which is abo ve
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
 
    }

        function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        // what this is going to have
        // price feed address
        // more stuff, so we make a struct for this STUFF which is abo ve
        NetworkConfig memory ethConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419 // Sepolia ETH/USD price feed address
        });
        return ethConfig;
 
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig; // if we already have a price feed address, return it
        }
        // what this is going to have
        // price feed address
        // more stuff, so we make a struct for this STUFF which is abo ve

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_ANSWER); // 2000 USD in 18 decimals
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed) // address of the mock price feed
        });
        return anvilConfig;

    }

}

