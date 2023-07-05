// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

import "./zkVickreyAuction.sol";
//CONTRATO GENERADOR SUBASTAS
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

    /** 
     * createAuction(string memory name ,address _owner_address, uint _min_fee, uint _bid_period, uint _reveal_period, uint _max_bidders, string memory _url, address _token_address)
     * @notice Crea una nueva subasta con los parámetros asociados. Técnicamente esta subasta es un nuevo proxy que redirige sus llamadas a la lógica registrada en el contrato UpgradeableBeacon desplegado en el constructor.
     * @param name Nombre de la subasta creada
     * @param _owner_address Dirección del subastador en la cual quiere recibir el pago
     * @param _min_fee Tasa mínima (mínimo retenido por el contrato al momento de la puja)
     * @param _bid_period Periodo de puja
     * @param _reveal_period Periodo del que disponen los interesados para verificar su puja.
     * @param _max_bidders Numero máximo de involucrados en la puja
     * @param _url Url del recurso a subastar, que ofrece contenido informativo
     * @param _token_address Dirección del token que representa la propiedad del objeto a subasta
     */
    function createAuction(string memory name ,address _owner_address, uint _min_fee, uint _bid_period, uint _reveal_period, uint _max_bidders, string memory _url, address _token_address) public onlyRegistered returns (address){ 
        BeaconProxy proxy = new BeaconProxy(auctionBeacon,
            abi.encodeWithSelector(zkVickreyAuctionC.initialize.selector,_owner_address, _min_fee , _bid_period, _reveal_period, _max_bidders, _url, address(this),_token_address)
        );
        auction_id+=1;
        auctions.push(Auction(auction_id,name,_owner_address,address(proxy),_url));
        auctionProxies[address(proxy)] = true;
        emit AuctionCreated(name, address(proxy));
        return address(proxy);
    }

    /** 
      * register()
      * @notice Realiza el registro de un usuario para que pueda actuar como subastador  
     */
    function register() public {
        require(!auctioneers[msg.sender], "Ya estas registrado");
        auctioneers[msg.sender] = true;
        auctioneersAddr.push(msg.sender);
    }
    /** 
      * banBidder (address bidder)
      * @notice Realiza la penalización de un postor sugerido.
      * @param bidder Postor afectado por la sanción
     */
    function banBidder (address bidder) external {
        require(auctionProxies[msg.sender], "Llamada realizada desde un contrato malicioso");
        bannedBidders[bidder] = true;
    }
    /** 
      * allAuctions()
      * @notice Muestra todas las subastas activas y pasadas
     */
     function allAuctions() public view returns (Auction [] memory){
        return auctions;
    }  
    /** 
      * isBidderBanned(address bidder)
      * @notice Comprueba si un postor dado ha quedado baneado
     */
    function isBidderBanned(address bidder) public view returns (bool){
        return bannedBidders[bidder];
    }
    /** 
      * changeBeaconImplementation(address implementation)
      * @notice Cambia de lógica de subasta a la que redirigen las llamadas los proxies subasta
     */
    function changeBeaconImplementation(address implementation) external isOwner() {
        UpgradeableBeacon(auctionBeacon).upgradeTo(implementation);
        emit Upgraded(implementation);
    }

}
