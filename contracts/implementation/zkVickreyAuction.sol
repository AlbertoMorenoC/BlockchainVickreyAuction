// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "../ElipticCurveTools.sol";

contract zkVickreyAuctionC is Initializable{

    address [] bidders;

    uint min_bid;
    uint bid_period;
    uint reveal_period;
    uint max_bidders;
    string url;

    uint total_bidders;

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
    function register() public isNotFull returns (bool){
        total_bidders++;
        bidders.push(msg.sender);
        return true;
        
    }

    function bid() public{
        /*commit()*/
    }

    function commit(uint256 _r , uint256 _m) internal {
        /*c = m*G + r*H mod p*/

    }

    function verify(uint256 _r , uint256 _m, uint256 id) internal{

    }

    function testImplementation() public pure returns (string memory){
        return "zkVickreyImplementation";
    }

}

