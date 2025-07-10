// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol"; // Importing the script to deploy FundMe contract

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user"); // This is a test address, not a real one
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether; // Starting balance for the USER

    function setUp() external { // US --> fundMeTest --> FundMe
        //fundMe = new FundMe();
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run(); /**This will deploy the FundMe contract and return the instance of the contract
         This is the same as calling fundMe = new FundMe(); */

        vm.deal(USER, 10 ether); // Giving USER 10 ETH for testing
    }

    function testMinimumDollarsIsFive() public view{
        assertEq(fundMe.MINIMUM_USD (), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        //console.log(fundMe.i_owner());
        //console.log(msg.sender);

        assertEq(fundMe.getOwner(), msg.sender); 

        // address(this) is the address of the contract that is running this code
        // we use msg.sender is the address of the actual contract that deployed this code i.e FundMe.sol
    }

    function testPriceFeedVersion() public view{
        uint256 version = fundMe.getVersion();
        console.log(version);
        assertEq(version, 4); // Sepolia ETH/USD price feed version
    } 

    function testFundFailsWithoutEnoughETH() public{
        vm.expectRevert();// Next line should revert
        //assert(This tx fails?reverts)

        fundMe.fund(); // This will fail because we are not sending enough ETH
    }

    function testFundUpdatesFundedDataStructure() public{
        vm.prank(USER); // Next txn will be sent by USER
        fundMe.fund{value: SEND_VALUE}(); // Sending 10 ETH, which is more than 5 USD

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFundersAddresToArrayOfFunder() public{
        vm.prank(USER); 
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0);
        assertEq(funder,USER); // Check if the first funder is USER

    }

    modifier funded(){
       vm.prank(USER); 
       fundMe.fund{value: SEND_VALUE}(); 
       _; // This modifier will fund the contract before running the test
    }

    function testOnlyOwnerCanWithdraw() public funded{
        //vm.prank(USER);   WE DONT NEED THIS LINE BECAUSE WE ARE USING THE FUNDED MODIFIER 
        //fundMe.fund{value: SEND_VALUE}();

        vm.expectRevert(); 
        fundMe.withdraw();

    }

    function testWithdrawWithSingleFunder() public funded{
        // Arange - Setting up the test environment
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act - Perform the action we are performing
        vm.prank(fundMe.getOwner()); // The owner is the one who can withdraw
        fundMe.withdraw(); // Actual withdraw we wrote the test for

        // Assert - Check the results
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0); // Check if the balance of the FundMe contract is 0
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);

    }

    function testWithdrawWithMultipleFunders() public funded{
        // Arrange
        uint160 numberOfFunders = 10; //UINT160 has same bytes as address so we use it instead of 256
        uint160 startingFunderIndex =1;
        for (uint160 i = startingFunderIndex ; i < numberOfFunders; i++){
            // vm.prank CREATES new address
            // vm.deal FUNDS new address
            hoax(address(i), SEND_VALUE); // This will create a new address and send SEND_VALUE to it
            fundMe.fund{value: SEND_VALUE}(); // Fund the contract with SEND_VALUE
        }

        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        // ACT
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // ASSERT 
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
    }

    function testWithdrawWithMultipleFundersCheaper() public funded{
        // Arrange
        uint160 numberOfFunders = 10; //UINT160 has same bytes as address so we use it instead of 256
        uint160 startingFunderIndex =1;
        for (uint160 i = startingFunderIndex ; i < numberOfFunders; i++){
            // vm.prank CREATES new address
            // vm.deal FUNDS new address
            hoax(address(i), SEND_VALUE); // This will create a new address and send SEND_VALUE to it
            fundMe.fund{value: SEND_VALUE}(); // Fund the contract with SEND_VALUE
        }

        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        // ACT

        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        // ASSERT 
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
    }

}

// US --> fundMeTest --> FundMe  //meaning we as a fundMeTest contract are deploying the FundMe contract