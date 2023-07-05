// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./auxiliarContracts/ElipticCurveTools.sol";
import "./AuctionFactory.sol";
import "./auxiliarContracts/AuctionObjectToken.sol";
//CONTRATO SUBASTA ÁNONIMA
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
    mapping(address => bool) isVerifiedBidder;

    SpecialBidder public max_bidder;
    SpecialBidder public second_max_bidder;

    address owner_address;
    uint min_fee;
    uint bid_period;
    uint reveal_period;
    uint max_bidders;
    string url;
    address factoryAddress;
    address token_address;

    uint open_time;
    uint actual_time;
    uint total_bidders;
    bool isBanned;

    //Variables con el propósito de testing y la implementación de un frontend
    address [] testRegisters;
    Commit [] testCommits;
    bytes32 [] testVerify;
    event AuctionCommits (Commit [] commits);
    event AuctionVerification(bytes32 [] verifications);

    event ActualRegisters(address [] registers);
    event AuctionMetadata(uint b_p, uint r_p, uint min_f);
    event CommitEvent(Commit commit);
    event isCommitVerified(bool verified);
    event isBidderWinner(bool isWinner);

    modifier isRegistered() {
        require(bidders[msg.sender], "No estas registrado");
        _;
    }

    modifier hasNotBid(){
        require(!safeBid[msg.sender], "Ya has pujado");
        _;
    }

    modifier hasBid(){
        require(safeBid[msg.sender], "No ha pujado aun");
        _;
    }

    modifier isNotFull () {
        require(total_bidders < max_bidders, "No hay huecos libres en la subasta");
        _;
    }

    modifier isBidPhase() {
        require(block.timestamp < bid_period , "La fase de pujas ha finalizado");
        _;
    }

    modifier isVerifyPhase() {
        require(block.timestamp > bid_period && block.timestamp < reveal_period, "La subasta no esta en fase de verificacion");
        _;
    }

    modifier isRevealPhase() {
        require(block.timestamp > reveal_period, "La fase de reclamo de recompensas no ha comenzado");
        _;
    }

    modifier isBidderVerified() {
        require(isVerifiedBidder[msg.sender], "No ha verificado correctamente su puja");
        _;
    }

    modifier isAuctionApproved() {
        require(AuctionObjectToken(token_address).isCallerApproved(), "El subastador no ha concedido permiso sobre el token objeto de subasta");
        _;
    }

    modifier isNotBanned() {
        require(!isBanned, "Ha sido baneado de la subasta");
        _;
    }



    /** 
     * initialize(address _owner_address, uint _min_fee, uint _bid_period, uint _reveal_period, uint _max_bidders, string memory _url, address _factory_address, address _token_address)
     * @param _owner_address Dirección del subastador en la cual quiere recibir el pago
     * @param _min_fee Tasa mínima (mínimo retenido por el contrato al momento de la puja)
     * @param _bid_period Periodo de puja
     * @param _reveal_period Periodo del que disponen los interesados para verificar su puja.
     * @param _max_bidders Numero máximo de involucrados en la puja
     * @param _url Url del recurso a subastar, que ofrece contenido informativo
     * @param _factory_address Dirección del Contrato Generador Subastas que desplegó esta lógica
     * @param _token_address Dirección del token que representa la propiedad del objeto a subasta
     */
    function initialize(address _owner_address, uint _min_fee, uint _open_time, uint _bid_period, uint _reveal_period, uint _max_bidders, string memory _url, address _factory_address, address _token_address) external initializer{
        owner_address = _owner_address;
        open_time = _open_time;
        min_fee = _min_fee;
        bid_period =_bid_period;
        reveal_period =_reveal_period;
        max_bidders = _max_bidders;
        url = _url;
        factoryAddress = _factory_address;
        token_address = _token_address;
    }

    /** 
      * register()
      * @notice Los usuarios realizarán un registro antes de poder pujar.W
      * !Advertencia: no se podrán realizar mas de max_bidders registros 
     */
    function register() public isNotFull() returns (bool){
        total_bidders++;
        bidders[msg.sender] = true;
        testRegisters.push(msg.sender);
        return true;
        
    }

    /** 
      * commit(uint256 _r , uint256 _m)
      * @notice Realiza un compromiso haciendo uso de la solución de curva elíptica diseñada e importada,
      * y devuelve el commit en componentes Jacobi. Esta función es utilizada únicamente de forma interna en la verificación,
      * el compromiso de cada usuario se realiza de forma local.
      * @param _r Representa el valor aleatorio del compromiso Pedersen
      * @param _m Representa el valor de la oferta que se esconde detrás del compromiso Pedersen
      * !Advertencia: es necesario el registro para poder interactuar en la puja  
     */

    function commit(uint256 _r , uint256 _m) internal view isRegistered() returns (uint c1, uint c2, uint c3){
        /*1.r*G*/
        uint x1;
        uint y1;
        uint z1;
        (x1,y1,z1) = ECTools.toJacobi(ECTools.Gx, ECTools.Gy);
        (x1,y1,z1) = ECTools.cMult(x1, y1, z1, _r);

        /*2.m*H*/
        uint x2;
        uint y2;
        uint z2;
        (x2,y2,z2) = ECTools.toJacobi(ECTools.Hx, ECTools.Hy);
        (x2,y2,z2) = ECTools.cMult(x2, y2, z2, _m);
        
        /*3.r*G + m*H*/
        (c1,c2,c3) = ECTools.cAdd(x1,y1,z1, x2,y2,z2);

        return (c1,c2,c3);
    }

    /** 
      * bid(uint c1, uint c2, uint c3)
      * @notice Se suministra el compromiso para registrarlo como puja del postor.
      * @param c1 Primera componente del compromiso Pedersen
      * @param c2 Segunda componente del compromiso Pedersen
      * @param c3 Tercera componente del compromiso Pedersen
      * !Advertencia: es necesario el registro para poder interactuar en la puja  
      * !Advertencia: solo es posible pujar una vez por postor
      * !Advertencia: es necesario enviar el ether asociado a la tasa mínima de la subasta
     */
    function bid(uint c1, uint c2, uint c3) isRegistered() hasNotBid() isAuctionApproved() isBidPhase() payable external{
        require(msg.value == min_fee,"No has enviado la tasa minima de participacion");
        commits[msg.sender] = Commit(c1,c2,c3);
        testCommits.push(Commit(c1,c2,c3));
        safeBid[msg.sender] = true;
    }

    /** 
      * verify(uint256 _r , uint256 _m)
      * @notice Una vez la fase de pujas ha finalizado, el postor puede suministrar 
      * sus parámetros secretos para comprobar su compromiso. Si no se verifica correctamente, el postor queda baneado.
      * @param _r Representa el valor aleatorio del compromiso Pedersen
      * @param _m Representa el valor de la oferta que se esconde detrás del compromiso Pedersen
      * !Advertencia: es necesario el registro para poder verificar el compromiso
      * !Advertencia: solo es posible la verficacion cuando haya trascurrido la fase de puja
      * !Advertencia: es necesario enviar el ether asociado al valor de la puja que se cifró en el compromiso
     */
    function verify(uint256 _r , uint256 _m) isRegistered() hasBid() isVerifyPhase() isNotBanned() external payable {
        uint x;
        uint y;
        uint z;
        bool isVerified;
        (x,y,z) = commit(_r,_m);
        Commit memory rcvdCommit = Commit(x,y,z);
        testCommits.push(rcvdCommit);

        bytes32 storedCommit = keccak256(abi.encodePacked(commits[msg.sender].c1,commits[msg.sender].c2,
        commits[msg.sender].c3));
        bytes32 actualCommit = keccak256(abi.encodePacked(rcvdCommit.c1,rcvdCommit.c2,
        rcvdCommit.c3));
        testVerify.push(storedCommit);
        testVerify.push(actualCommit);

        isVerified = (storedCommit == actualCommit); 

        if (isVerified) {
            require(msg.value == _m, "No ha pagado el valor de la oferta");
            isVerifiedBidder[msg.sender] = true;
            amountToRefund[msg.sender] = msg.value + min_fee;
            if(_m > max_bidder.value){
                    second_max_bidder.bidder = max_bidder.bidder;
                    second_max_bidder.value = max_bidder.value;
                    max_bidder.bidder = msg.sender;
                    max_bidder.value = _m;
                    
            }else {
                if(_m > second_max_bidder.value){
                    second_max_bidder.bidder = msg.sender;
                    second_max_bidder.value = _m;
                }
            }
            emit isCommitVerified(isVerified);
        }else{
            AuctionFactoryC factory = AuctionFactoryC(factoryAddress);
            factory.banBidder(msg.sender);
            isBanned = true;
        }
        

    }

    /** 
      * claimReward()
      * @notice Los postores consultan si son los ganadores de la puja, y si no es así, se les devuelve
      * la cantidad retenida. El contrato destinará la cantidad pujada del ganador al dueño, y a él ganador
      * se le atribuye la propiedad del token que representa el objeto a subasta
      * !Advertencia: es necesario el registro para poder reclamar la recompensa
      * !Advertencia: solo es posible el reclamo cuando haya trascurrido el tiempo de verificación
     */
    function claimReward() isRegistered() hasBid() isRevealPhase() isBidderVerified() external {
        if(msg.sender == max_bidder.bidder){
            delete amountToRefund[msg.sender];
            payable(msg.sender).transfer((max_bidder.value-second_max_bidder.value)+min_fee);
            AuctionObjectToken(token_address).transfer(msg.sender);
            payable(owner_address).transfer(second_max_bidder.value);
            emit isBidderWinner(true);
        }else {
            payable(msg.sender).transfer(amountToRefund[msg.sender]);
            delete amountToRefund[msg.sender];
            emit isBidderWinner(false);
        }
    }

    /** 
      * getMetadata()
      * @notice Utilizada por el frontend del sistema para obtener tiempos de las fases de la subasta y presentarlos al usuario.
     */
    function getMetadata() public {
        emit AuctionMetadata(bid_period,reveal_period,min_fee);
    }
    
    //Función para obtener logs de la subasta. Permiten comprender que ha sucedido después de la ejecución de funciones importantes.
    function testRegistered() public {
        emit ActualRegisters(testRegisters);
    }

    //Función para obtener logs de la subasta. Permiten comprender que ha sucedido después de la ejecución de funciones importantes.
    function testCommited() public {
        emit AuctionCommits(testCommits);
    }

    //Función para obtener logs de la subasta. Permiten comprender que ha sucedido después de la ejecución de funciones importantes.
    function testVerification() public {
        emit AuctionVerification(testVerify);
    }


}

