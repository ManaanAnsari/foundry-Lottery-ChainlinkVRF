// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;
import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {Raffle} from "../src/Raffle.sol";

contract CreateSubscription is Script {
    function createSubscriptionUsingConfig() public returns (uint64) {
        HelperConfig helperConfig = new HelperConfig();
        (, , address vrfCoordinator, , , , , uint256 deployerkey) = helperConfig
            .activeNetworkConfig();
        return createSubscription(vrfCoordinator, deployerkey);
    }

    function createSubscription(
        address vrfCoordinator,
        uint256 deployerkey
    ) public returns (uint64) {
        console.log("Creating subscription on chainid: ", block.chainid);
        vm.startBroadcast(deployerkey);
        VRFCoordinatorV2Mock vrfCoordinatorContract = VRFCoordinatorV2Mock(
            vrfCoordinator
        );
        uint64 sibId = vrfCoordinatorContract.createSubscription();
        vm.stopBroadcast();
        console.log("Subscription ID: ", sibId);
        console.log("plz update in helperconfig");
        return sibId;
    }

    function run() external {
        // This script is a placeholder for the interactions between the Raffle contract and the HelperConfig contract
    }
}

contract FundSubscription is Script {
    uint96 public constant FUND_AMOUNT = 3 ether; // 3 LINK

    function fundSubscriptionUsingConfig() public {
        HelperConfig helperConfig = new HelperConfig();
        (
            ,
            ,
            address vrfCoordinator,
            ,
            uint64 subscriptionId,
            ,
            address link,
            uint256 deployerkey
        ) = helperConfig.activeNetworkConfig();
        fundSubscription(vrfCoordinator, subscriptionId, link, deployerkey);
    }

    function fundSubscription(
        address vrfCoordinator,
        uint64 subscriptionId,
        address link,
        uint256 deployerkey
    ) public {
        console.log("funding sub: ", subscriptionId);
        console.log("vrfCoordinator: ", vrfCoordinator);
        console.log("chainid: ", block.chainid);
        if (block.chainid == 31337) {
            // envil
            vm.startBroadcast(deployerkey);
            VRFCoordinatorV2Mock vrfCoordinatorContract = VRFCoordinatorV2Mock(
                vrfCoordinator
            );
            vrfCoordinatorContract.fundSubscription(
                subscriptionId,
                FUND_AMOUNT
            );
            vm.stopBroadcast();
        } else {
            vm.startBroadcast(deployerkey);
            LinkToken linkContract = LinkToken(link);
            linkContract.transferAndCall(
                vrfCoordinator,
                FUND_AMOUNT,
                abi.encode(subscriptionId)
            );
            vm.stopBroadcast();
        }
    }

    function run() external {
        // This script is a placeholder for the interactions between the Raffle contract and the HelperConfig contract
    }
}

contract AddConsumer is Script {
    function addConsumerUsingConfig(address raffle) public {
        HelperConfig helperConfig = new HelperConfig();
        (
            ,
            ,
            address vrfCoordinator,
            ,
            ,
            uint64 subscriptionId,
            address link,
            uint256 deployerkey
        ) = helperConfig.activeNetworkConfig();
        addConsumer(vrfCoordinator, raffle, subscriptionId, deployerkey);
    }

    function addConsumer(
        address vrfCoordinator,
        address raffle,
        uint64 subscriptionId,
        uint256 deployerkey
    ) public {
        console.log("Adding consumer: ", raffle);
        console.log("vrfCoordinator: ", vrfCoordinator);
        console.log("chainid: ", block.chainid);
        vm.startBroadcast(deployerkey);
        VRFCoordinatorV2Mock vrfCoordinatorContract = VRFCoordinatorV2Mock(
            vrfCoordinator
        );
        vrfCoordinatorContract.addConsumer(subscriptionId, raffle);
        vm.stopBroadcast();
    }

    function run() external {
        address contractAddress = DevOpsTools.get_most_recent_deployment(
            "Raffle",
            block.chainid
        );
        Raffle raffle = Raffle(contractAddress);
        addConsumerUsingConfig(address(raffle));
    }
}
