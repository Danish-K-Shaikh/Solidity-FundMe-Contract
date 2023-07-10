//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./priceFeeder.sol";

error NotOwner(string e_msg);

contract fundMe {
    using priceFeeder for uint256;

    address public immutable owner;
    mapping(address => uint256) public funderToAmt;
    address[] public funders;
    uint256 public constant MINIMUM_USD = 10 * 10 ** 18;
    string constant MINIMUM_USD_STR = "10 $";
    
    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) revert NotOwner("You are not authorized to perform this action");
        _;
    }

    function fund() public payable {
        require(msg.value.getConversionRate() >= MINIMUM_USD, string.concat("Minimum accepted amount is ", MINIMUM_USD_STR));
        funderToAmt[msg.sender] += msg.value;
        if(msg.value == funderToAmt[msg.sender]) funders.push(msg.sender);
    }

    function withdraw() public onlyOwner {
        for(uint256 index = 0;index < funders.length; index++) {
            address funder = funders[index];
            funderToAmt[funder] = 0;
        }
        funders = new address[](0);

         (bool sendSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
         require(sendSuccess, "Withdraw failed");
    }

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }
}