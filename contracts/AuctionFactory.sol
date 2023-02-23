// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

import "./implementation/zkVickreyAuction.sol";

contract AuctionFactoryC {

    struct Auction {
        uint auction_id;
        string url;
        address auction_proxy;
    }

    Auction [] auctions;
    address [] auctioneersAddr;
    mapping (address => bool) public auctioneers;

    address auctionBeacon;
    address public logicContract;

    modifier onlyRegistered () {
        require(auctioneers[msg.sender]);
        _;
    }

    constructor (address _beaconOwner)  {
        UpgradeableBeacon _auctionBeacon = new UpgradeableBeacon(address(new zkVickreyAuctionC()));
        _auctionBeacon.transferOwnership(_beaconOwner);
        auctionBeacon = address(_auctionBeacon);
    }


    function createAuction(uint _auction_id, uint _min_bid, uint _bid_period, uint _reveal_period, uint _max_bidders, string memory _url) public onlyRegistered returns (address){ 
        BeaconProxy proxy = new BeaconProxy(auctionBeacon,
            abi.encodeWithSelector(zkVickreyAuctionC.initialize.selector, _min_bid, _bid_period, _reveal_period, _max_bidders, _url)
        );
        auctions.push(Auction(_auction_id,_url,address(proxy)));
        return address(proxy);
    }

    function register() public {
        require(!auctioneers[msg.sender], "Ya estas registrado");
        auctioneers[msg.sender] = true;
        auctioneersAddr.push(msg.sender);
    }

    function allAuctions() public view returns (Auction [] memory){
        return auctions;
    }

    /*function allAuctionProxies() public view returns (address[] memory){
        return auction_proxies;
    }*/

    /*function allAuctioneers() public view returns (address[] memory){
        return auctioneersAddr;
    }*/

    

}