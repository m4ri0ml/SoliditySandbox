/* 
    
    This contract is used to check the price of ETH at a given time using Chainlink 
    as defaul source of truth and Tellor as a fallback option. Its my attempt at handling
    several Oracle failures only by looking at Liquity's spec and following the same assumptions

    SPEC: https://www.liquity.org/blog/price-oracles-in-liquity

    DISCLAIMER: This code is not tested by a third-party, does not fully follow 
    Liquity's spec (WIP) and should not be deployed to a critical production environment. 

*/

pragma solidity ^0.8.0;

import "./interfaces/AggregatorV3Interface.sol";
import "./interfaces/UsingTellor.sol";

contract ETHPriceProvider is UsingTellor {

    test

    AggregatorV3Interface internal clPriceFeed;
    uint256 internal constant requestId = 1;
    uint256 internal latestUpdate;
    uint256 internal maxTimeBetweenUpdates = 4 hours;
    uint256 public latestETHPrice = 0;

    struct CLData {
        uint80 roundId;
        int256 price;
        uint256 startedAt;
        uint256 updatedAt;
        uint80 answeredInRound;
    }

    constructor(address _clPriceFeed, address _tellorAddress) UsingTellor(_tellorAddress) {
        priceFeed = AggregatorV3Interface(_clPriceFeed);
    }

    function getETHPrice() public returns(uint256) {
        // Check if its the first contract call
        if (latestETHPrice == 0) {
            latestETHPrice = getLatestChainlinkETHPrice();
            latestUpdate = block.timestamp;

            return latestETHPrice;
        }

        CLData memory clData = getLatestChainlinkETHData();
        bool clOkey = checkChainlinkHealth(clData);

        // If Chainlink is healthy we continue working with its price data
        if (clOkey) {
            uint256 clPrice = getLatestChainlinkETHPrice();
            uint256 tellorPrice = getLatestTellorETHPrice();

            // If Chainlink price deviates more than 50% from previous price we compare it to Tellor's price,
            // if they match price is considered correct. If they dont match we check if Tellor's price
            // also deviates more than 50% from previous price, if true we default to latest price update.
            if (checkPriceDeviation(latestETHPrice, clPrice)) {
                if (clPrice == tellorPrice) {
                    return clPrice;
                } 
                
                if (checkPriceDeviation(latestETHPrice, tellorPrice)) {
                    return latestETHPrice;
                }

                return tellorPrice;
            }
        } else {
            uint256 tellorPrice = getLatestTellorETHPrice();
            return tellorPrice;
        }

    }

    function checkChainlinkHealth(CLData memory clData) internal view returns(bool) {
        if (clData.updatedAt > block.timestamp) return false; // updatedAt timestamp is in the future
        if (clData.updatedAt == 0) return false; // updatedAt timestamp = zero
        if (clData.price == 0) return false; // price = 0
        if ((block.timestamp - clData.updatedAt) > maxTimeBetweenUpdates) return false; // stale price feed

        return true;
    }

    function checkPriceDeviation(uint256 lastPrice, uint256 newPrice) internal pure returns (bool) {
        uint256 halfLastPrice = lastPrice / 2;

        if (newPrice > lastPrice) {
            uint256 increase = newPrice - lastPrice;
            return increase > halfLastPrice;
        } else {
            uint256 decrease = lastPrice - newPrice;
            return decrease > halfLastPrice;
        }
    }

    function getLatestChainlinkETHData() public view returns (CLData memory) {
        (
            uint80 roundId,
            int256 price,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();

        return CLData(roundId, price, startedAt, updatedAt, answeredInRound);
    }

    // Although the Chainlink interfaces function returns a signed integer in this case
    // we assume ETH price cant be negative so we return uint256
    function getLatestChainlinkETHPrice() private view returns (uint256) {
        (, uint256 price, , ,) = priceFeed.latestRoundData();
        return price;
    }

    function getLatestTellorETHPrice() private view returns (uint256) {
        // Ensure that there is data available
        require(isDataNew(requestId), "Data is stale.");
        (bool ifRetrieve, uint256 value, ) = getDataBefore(requestId, block.timestamp - 1 hours);
        require(ifRetrieve, "Failed to retrieve data.");

        return value;
    }
}