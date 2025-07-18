// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";
import {console} from "forge-std/console.sol";


contract FundFundMe is Script{
    uint256 constant SEND_VALUE = 0.01 ether;
    function fundFundMe(address mostRecentlyDeployed) public{
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded FundMe is %s", SEND_VALUE);
    }

    function run() external{ 
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundME", 
            block.chainid
        );
        vm.startBroadcast();
        fundFundMe(mostRecentlyDeployed);
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentlyDeployed) public{
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
    }

    function run() external{ 
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundME", 
            block.chainid
        );
        vm.startBroadcast();
        withdrawFundMe(mostRecentlyDeployed);
        vm.stopBroadcast();
    }

}  