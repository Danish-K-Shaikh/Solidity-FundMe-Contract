// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library priceFeeder {
    function getPrice() internal view returns(uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0x326C977E6efc84E512bB9C30f76E30c160eD06FB // goerli contract
        );
        (, int256 price,,,) = priceFeed.latestRoundData();
        // chainlink pricefeed has 8 decimal places in response thus we need to add 10 more to match wei unit
        return uint256(price * 1e10);
    }

    function getConversionRate(uint256 ethAmount) internal view returns(uint256)
    {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd;
    }
}