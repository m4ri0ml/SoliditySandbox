/* 
    
    This contract is used to check the price of ETH at a given time using Chainlink 
    as defaul source of truth and Tellor as a fallback option. Its my attempt at handling
    several Oracle failures only by looking at Liquity's spec and following the same assumptions

    SPEC: https://www.liquity.org/blog/price-oracles-in-liquity

    DISCLAIMER: This code is not tested by a third-party, does not fully follow 
    Liquity's spec (WIP) and should not be deployed to a critical production environment. 

*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/AggregatorV3Interface.sol";
import "./interfaces/UsingTellor.sol";

contract ETHPriceProvider is UsingTellor {

    AggregatorV3Interface internal clPriceFeed;
    bytes public queryData = abi.encode("SpotPrice", abi.encode("eth", "usd"));
    bytes32 public queryId = keccak256(queryData);

    uint256 internal latestUpdate;
    uint256 internal maxTimeBetweenUpdates = 4 hours;
    uint256 public latestPrice;

    struct ChainlinkData {
        uint80 roundId;
        int256 price;
        uint256 startedAt;
        uint256 updatedAt;
        uint80 answeredInRound;
    }

    struct TellorData {
        uint256 value;
        uint256 timestamp;
        uint256 age;
    }

    constructor(address _clPriceFeed, address payable _tellorAddress) UsingTellor(_tellorAddress) {
        clPriceFeed = AggregatorV3Interface(_clPriceFeed);
    }

    function getETHPrice() public returns(uint) {
        // Check if its the first contract call
        if (latestPrice == 0) {
            latestPrice = getLatestChainlinkETHPrice();
            latestUpdate = block.timestamp;

            return uint(latestPrice);
        }

        ChainlinkData memory clData = getLatestChainlinkETHData();
        bool clOkey = checkChainlinkHealth(clData);

        TellorData memory tellorData = getLatestTellorETHData();
        bool tellorOkey = checkTellorHealth(tellorData);

        uint256 clPrice = getLatestChainlinkETHPrice();
        uint256 tellorPrice = getLatestTellorETHPrice();

        // If Chainlink is healthy we continue working with its price data
        if (clOkey) {

            // If Chainlink price deviates more than 50% from previous price we compare it to Tellor's price,
            // if they match price is considered correct. If they dont match we check if Tellor's price
            // also deviates more than 50% from previous price, if true we default to latest price update.
            if (checkPriceDeviation(latestPrice, clPrice)) {
                if (clPrice == tellorPrice) {
                    return clPrice;
                } 
                
                // Chainlink is broken so we take tellor's price and if it deviates we fallback to latest good price.
                if (checkPriceDeviation(latestPrice, tellorPrice)) {
                    return latestPrice;
                }

                // Chainlink is broken but Tellor is working fine so we use Tellor as oracle.
                return tellorPrice;
            
            // Chainlink is healthy and has not deviated more than 50% from lastPrice.
            } else {
                return clPrice;
            }

        // Chainlink not healthy
        } else {
            
            // If Tellor is healthy we continue working with its price data
            if (tellorOkey) {

                if (checkPriceDeviation(latestPrice, tellorPrice)) {
                    return latestPrice;
                }

                return tellorPrice;
            }

            return latestPrice;
        }

    }

    function checkChainlinkHealth(ChainlinkData memory clData) internal view returns(bool) {
        if (clData.updatedAt > block.timestamp) return false; // updatedAt timestamp is in the future
        if (clData.updatedAt <= 0) return false; // updatedAt timestamp <= zero
        if (clData.price <= 0) return false; // price <= 0
        if ((block.timestamp - clData.updatedAt) > maxTimeBetweenUpdates) return false; // stale price feed

        return true;
    }

    function checkTellorHealth(TellorData memory tellorData) internal view returns(bool) {
        if (tellorData.value <= 0) return false;
        if (tellorData.timestamp <= 0) return false;
        if (tellorData.timestamp > block.timestamp) return false;
        if ((block.timestamp - tellorData.timestamp) > maxTimeBetweenUpdates) return false;

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

    function getLatestChainlinkETHData() public view returns (ChainlinkData memory) {
        (
            uint80 roundId,
            int256 price,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        ) = clPriceFeed.latestRoundData();

        return ChainlinkData(roundId, price, startedAt, updatedAt, answeredInRound);
    }

    function getLatestTellorETHData() public view returns (TellorData memory) {
        (
            bytes memory value,
            uint256 timestamp
        ) = getDataBefore(queryId, block.timestamp - 30 minutes);

        uint256 age = timestamp - block.timestamp;
        uint256 price = _sliceUint(value);

        return TellorData(price, timestamp, age);
    }

    // Although the Chainlink interfaces function returns a signed integer in this case
    // we assume ETH price cant be negative so we return uint256
    function getLatestChainlinkETHPrice() private view returns (uint256) {
        (, int256 price, , ,) = clPriceFeed.latestRoundData();
        return uint(price);
    }

    function getLatestTellorETHPrice() private view returns (uint256) {
        (bytes memory value, ) = getDataBefore(queryId, block.timestamp - 1 hours);
        uint256 price = _sliceUint(value);

        return price;
    }
}