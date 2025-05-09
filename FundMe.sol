// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

import { PriceConverter } from "./PriceConverter.sol";

error NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MIN_USD = 5e18;

    address[] public funders;

    mapping (address funder => uint256 amountFunded) public addressToAmountFunded;
    
    address public immutable i_owner;

    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable {
        require(msg.value.getConversionRate() > MIN_USD, "Didn't sent enough ETH");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        for (uint256 i = 0; i < funders.length; i++) {
            address funder = funders[i];
            addressToAmountFunded[funder] = 0;
        }

        funders = new address[](0);
        
        /* 
            withdrawing
            "transfer" => automatically reverts if fails
                payable(msg.sender).transfer(address(this).balance);
            "send" => reverts using require keyword if fails
                bool sendSuccess = payable(msg.sender).send(address(this).balance);
                require(sendSuccess, "Send Failed!");
        */
        // "call" 
        (bool callSuccess, ) = payable (msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Send Failed!");
        revert();
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) { revert NotOwner(); }
        /* 
           _ below means first run the modifier then the function, 
           above means first run the function the modifier 
        */
        _;
    }
    
}