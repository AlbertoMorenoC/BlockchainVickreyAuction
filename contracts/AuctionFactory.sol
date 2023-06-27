// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

import "./implementation/zkVickreyAuction.sol";

contract AuctionFactoryC {

    struct Auction {
        uint auction_id;
        string name;
        address owner_address;
        address auction_proxy;
        string url;
    }

    Auction [] auctions;
    mapping (address => bool) public auctioneers;
    mapping (address => bool) public bannedBidders;
    mapping (address => bool) public auctionProxies;

    address [] auctioneersAddr;
    address auctionBeacon;
    address beaconOwner;
    address public logicContract;
    uint auction_id;

    event AuctionCreated(string name, address indexed addr);
    event senderEvent(address adrr);
    event Upgraded(address implementation);

    modifier onlyRegistered () {
        require(auctioneers[msg.sender]);
        _;
    }

    modifier isOwner () {
        require(msg.sender == beaconOwner);
        _;
    }
    

    constructor (address _beaconOwner)  {
        zkVickreyAuctionC logicContract = new zkVickreyAuctionC();
        UpgradeableBeacon _auctionBeacon = new UpgradeableBeacon(address(logicContract));
        _auctionBeacon.transferOwnership(_beaconOwner);
        auctionBeacon = address(_auctionBeacon);
        beaconOwner = _beaconOwner;
    }


    function createAuction(string memory name ,address _owner_address, uint _min_fee, uint _bid_period, uint _reveal_period, uint _max_bidders, string memory _url, address _token_address) public onlyRegistered returns (address){ 
        BeaconProxy proxy = new BeaconProxy(auctionBeacon,
            abi.encodeWithSelector(zkVickreyAuctionC.initialize.selector,_owner_address, _min_fee, block.timestamp, _bid_period, _reveal_period, _max_bidders, _url, address(this),_token_address)
        );
        auction_id+=1;
        auctions.push(Auction(auction_id,name,_owner_address,address(proxy),_url));
        auctionProxies[address(proxy)] = true;
        emit AuctionCreated(name, address(proxy));
        return address(proxy);
    }

    function register() public {
        require(!auctioneers[msg.sender], "Ya estas registrado");
        auctioneers[msg.sender] = true;
        auctioneersAddr.push(msg.sender);
    }

    function banBidder (address bidder) external {
        require(auctionProxies[msg.sender], "Llamada realizada desde un contrato malicioso");
        bannedBidders[bidder] = true;
    }

     function allAuctions() public view returns (Auction [] memory){
        return auctions;
    }  

    function isBidderBanned(address bidder) public view returns (bool){
        return bannedBidders[bidder];
    }

    function changeBeaconImplementation(address implementation) external isOwner() {
        UpgradeableBeacon(auctionBeacon).upgradeTo(implementation);
        emit Upgraded(implementation);
    }

}