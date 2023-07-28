//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "../forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";


// This is the contract that allows us to set the price feed address for the network we are on.
// We have a different price feed address for each network.
// We need to know the price of ETH in order to calculate the price of the Anvil product in USD.
// We use the price feed address to get the price of ETH.
// This contract is deployed on each network.
// We use the network ID to determine which price feed to use.
// The price feed is updated by Chainlink every 1 hour.

contract HelperConfig is Script {
        struct NetworkConfig{
            address priceFeed;
        }

        NetworkConfig public activeNetworkConfig;

        uint8 public constant DECIMALS = 8;
        int256 public constant INITIAL_PRICE = 2000e8;

        constructor(){
            if (block.chainid == 11155111){
                activeNetworkConfig = getSepoliaEthConfig();
            } else if (block.chainid == 1){
                activeNetworkConfig = getMainnetEthConfig();
            } else {
                activeNetworkConfig = getAnvilEthConfig();
            }
        }

        function getSepoliaEthConfig() public pure returns(NetworkConfig memory){
            NetworkConfig memory sepoliaConfig = NetworkConfig({
                priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
            });
            return sepoliaConfig;  
        }

        function getMainnetEthConfig() public pure returns(NetworkConfig memory){
            NetworkConfig memory mainnetConfig = NetworkConfig({
                priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
            });
            return mainnetConfig;  
        }

        function getAnvilEthConfig() public returns(NetworkConfig memory){
            if (activeNetworkConfig.priceFeed != address(0)){
                return activeNetworkConfig;
            }
              vm.startBroadcast();
                MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
                DECIMALS, 
                INITIAL_PRICE);
              vm.stopBroadcast();

                NetworkConfig memory anvilConfig = NetworkConfig({
                    priceFeed: address(mockPriceFeed)
                });
                return anvilConfig;
        }
    }