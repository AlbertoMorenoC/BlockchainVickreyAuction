// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "../ElipticCurveTools.sol";

contract zkVickreyAuctionC is Initializable{

    using ECTools for uint;

    struct Commit {
        uint c1;
        uint c2;
        uint c3;
    }

    struct SpecialBidder {
        address bidder;
        uint value;
    }

    mapping (address => bool) bidders;
    mapping (address => bool) safeBid;
    mapping (address => Commit) public commits;
    mapping (address => uint) amountToRefund;

    SpecialBidder max_bidder;
    SpecialBidder second_max_bidder;

    address owner_address;
    uint min_bid;
    uint bid_period;
    uint reveal_period;
    uint max_bidders;
    string url;

    uint open_time;
    uint actual_time;
    uint total_bidders;

    modifier isRegistered() {
        require(bidders[msg.sender]);
        _;
    }

    modifier hasNotBid(){
        require(!safeBid[msg.sender]);
        _;
    }

    modifier hasBid(){
        require(safeBid[msg.sender]);
        _;
    }

    modifier isNotFull () {
        require(total_bidders < max_bidders);
        _;
    }

    modifier isBidFinished() {
        require(actual_time > open_time+bid_period);
        _;
    }

    modifier isRevealFinished() {
        require(actual_time > open_time+bid_period+reveal_period);
        _;
    }


    /** 
     * @param _owner_address Dirección del subastador en la cual quiere recibir el pago
     * @param _min_bid Puja mínima (mínimo retenido por el contrato al momento de la puja)
     * @param _bid_period Periodo de puja
     * @param _reveal_period Periodo del que disponen los interesados para comprobar
     que su puja es menor a la ganadora (Bulletproof verification)
     * @param _max_bidders Numero máximo de involucrados en la puja
     * @param _url Url del recurso a subastar, que ofrece contenido informativo
     */
    function initialize(address _owner_address, uint _min_bid, uint _bid_period, uint _reveal_period, uint _max_bidders, string memory _url) external initializer{
        owner_address = _owner_address;
        min_bid = _min_bid;
        bid_period =_bid_period;
        reveal_period =_reveal_period;
        max_bidders = _max_bidders;
        url = _url;
        /*Call oracle for open_time -> open_time = */
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
      * commit()
      * @notice Realiza un commit haciendo uso de la solucion de curva elíptica diseñada e importada,
      * y devuelve el commit en componentes Jacobi (el usuario es responsable de pujar suministrando
      * el commit generado sobre la funcion bid())
      * !Advertencia: es necesario el registro para poder interactuar en la puja  
     */
    function commit(uint256 _r , uint256 _m) public isRegistered() returns (uint c1, uint c2, uint c3) {
        /*1.-r*G*/
        uint x1;
        uint y1;
        uint z1;
        (x1,y1,z1) = ECTools.toJacobi(ECTools.Gx, ECTools.Gy);
        (x1,y1,z1) = ECTools.cMult(x1, y1, z1, _r);

        /*1.-m*H*/
        uint x2;
        uint y2;
        uint z2;
        (x2,y2,z2) = ECTools.toJacobi(ECTools.Hx, ECTools.Hy);
        (x2,y2,z2) = ECTools.cMult(x2, y2, z2, _m);
        
        /*1.-r*G + m*H*/
        (c1,c2,c3) = ECTools.cAdd(x1,y1,z1, x2,y2,z2);

        safeBid[msg.sender] = true;
        return(c1,c2,c3);

    }

    /** 
      * bid()
      * @notice Se suministra el commit para registrarlo como puja del postor. Se pagará un minimo
      * para asegurar que el postor se compromete.
      * !Advertencia: es necesario el registro para poder interactuar en la puja  
      * !Advertencia: solo es posible pujar una única vez por postor
     */
    function bid(uint c1, uint c2, uint c3) isRegistered() hasNotBid() payable external{
        require(msg.value == min_bid,"You are not sending min_bid to participate");
        commits[msg.sender] = Commit(c1,c2,c3);
    }

    /** 
      * verify()
      * @notice Una vez la subasta ha finalizado (opentime + bid_period), el postor puede suministrar 
      * sus parametros secretos para comprobar el commitment. Si se verifica y corresponde con el ganador,
      * se devuelve un 2.
      * !Advertencia: es necesario el registro para poder verificar el commitment 
      * !Advertencia: solo es posible la verficacion cuando haya trascurrido el tiempo de puja (bid_period)
     */
    function verify(uint256 _r , uint256 _m) isRegistered() hasBid() isBidFinished() external payable returns (bool){
        uint x;
        uint y;
        uint z;
        bool isVerified;
        (x,y,z) = commit(_r,_m);
        Commit memory rcvdCommit = Commit(x,y,z);

        //Compare stored commit with calculated one using given parameters
        isVerified = keccak256(abi.encodePacked(commits[msg.sender].c1,commits[msg.sender].c1,
        commits[msg.sender].c2,commits[msg.sender].c2)) == keccak256(abi.encodePacked(rcvdCommit.c1,rcvdCommit.c2,
        rcvdCommit.c3)); 

        if (isVerified) {
            //check rest of deposit has been made
            require(msg.value == _m - min_bid);
            amountToRefund[msg.sender] = msg.value + min_bid;
            //select winner once bid time has finished
            if(_m > max_bidder.value){
                    max_bidder.bidder = msg.sender;
                    max_bidder.value = _m;
            }else {
                if(_m > second_max_bidder.value){
                    second_max_bidder.bidder = msg.sender;
                    second_max_bidder.value = _m;
                }
            }
            return true;
        }

        return false;
    }

    /** 
      * claimOwnership()
      * @notice Los postores consultan si son los ganadores de la puja, y si no es asi, se les devuelve
      * la cantidad retenida. El contrato destinará la cantidad pujada del ganador al dueño, y a él ganador
      * se le otorgará una validación de su nueva propiedad (a elección del subastador, por ejemplo, un token)
      * !Advertencia: es necesario el registro para poder verificar el commitment 
      * !Advertencia: solo es posible la verficacion cuando haya trascurrido el tiempo de revelado (reveal_period)
     */
    function claimOwnership() isRegistered() hasBid() isRevealFinished()  external returns (bool){
        if(msg.sender == max_bidder.bidder){
            delete amountToRefund[msg.sender];
            //Winner is returned the diff between max and secondmax values (Vickrey)
            payable(msg.sender).transfer(max_bidder.value - second_max_bidder.value);
            //Auctionner gets payed the second max bid
            payable(owner_address).transfer(second_max_bidder.value);
            return true;
        }else {
            //Non-winners got all of its bid value
            payable(msg.sender).transfer(amountToRefund[msg.sender]);
            delete amountToRefund[msg.sender];
            return false;
        }
    }
    

    function testImplementation() public pure returns (string memory){
        return "zkVickreyImplementation";
    }

}

