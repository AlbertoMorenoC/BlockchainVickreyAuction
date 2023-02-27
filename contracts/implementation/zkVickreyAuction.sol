// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "../ElipticCurveTools.sol";

contract zkVickreyAuctionC is Initializable{

    mapping (address => bool) bidders;

    uint min_bid;
    uint bid_period;
    uint reveal_period;
    uint max_bidders;
    string url;

    uint total_bidders;

    modifier isRegistered(address bidder) {
        require(bidders[bidder]);
        _;
    }

    modifier isNotFull () {
        require(total_bidders < max_bidders);
        _;
    }


    /** 
     * @param _min_bid Puja mínima
     * @param _bid_period Periodo de puja
     * @param _reveal_period Periodo del que disponen los interesados para comprobar
     que su puja es menor a la ganadora (Bulletproof verification)
     * @param _max_bidders Numero máximo de involucrados en la puja
     * @param _url Url del recurso a subastar, que ofrece contenido informativo
     */
    function initialize(uint _min_bid, uint _bid_period, uint _reveal_period, uint _max_bidders, string memory _url) external initializer{
        min_bid = _min_bid;
        bid_period =_bid_period;
        reveal_period =_reveal_period;
        max_bidders = _max_bidders;
        url = _url;
    }

    /** 
      * register()
      * @notice Los usuarios realizarán un registro antes de poder pujar.
      * !Advertencia: es necesario el registro para poder interactuar en la puja 
      * !Advertencia: no se podrán realizar mas de max_bidders registros 
     */
    function register() public isNotFull() returns (bool){
        total_bidders++;
        bidders[msg.sender] = true;
        return true;
        
    }

    /** 
      * bid()
      * @notice Realiza un commit haciendo uso de la solucion de curva elíptica diseñada e importada,
      * y devuelve el commit en dos componente (componentes x e y de la curva eliptica) que gestionará
      * el usuario asociado
      * !Advertencia: es necesario el registro para poder interactuar en la puja  
     */
    function bid(uint256 _r , uint256 _m) external isRegistered(msg.sender) returns (uint c1, uint c2) {
        /*1.-*m*G*/
        ElipticCurveToolsC ec = new ElipticCurveToolsC();
        uint x;
        uint y;
        uint z;
        (x,y,z) = ec.toJacobi(ec.Gx, ec.Gy);
    }

    function verify(uint256 _r , uint256 _m, uint256 id) internal{

    }

    function testImplementation() public pure returns (string memory){
        return "zkVickreyImplementation";
    }

}

