// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {console} from "forge-std/console.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        //Before startBroadcast --> Not a "real" txn, done to save gas
        
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPricefeed = helperConfig.activeNetworkConfig();


        //After stopBroadcast --> A "real" txn
        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUsdPricefeed);
        vm.stopBroadcast();
        console.log("FundMe deployed to:", address(fundMe));
        return fundMe;
    }
}
