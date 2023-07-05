// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//CONTRATO TOKEN OBJETO SUBASTA
contract AuctionObjectToken {

    string private _name;
    string private _metadata;

    address _owner;


   address private _tokenApproval;


    event Transfer(address indexed _from, address indexed _to);
    event Approval(address indexed _owner, address indexed _approve);


    constructor(string memory name_, string memory metadata_) {
        _name = name_;
        _metadata = metadata_;
        _owner = msg.sender;
    }

    /** 
      * name()
      * @notice Informa el nombre del token
     */
    function name() external view returns (string memory) {
        return _name;
    }

    /** 
      * metadata()
      * @notice Informa el url del documento informativo
     */
    function metadata() external view returns (string memory) {
        return _metadata;
    }

    /** 
      * ownerOfToken()
      * @notice Informa el propietario del token
     */
    function ownerOfToken() external view returns (address) {
        return _owner;
    }

    /** 
      * approve(address to)
      * @notice Aprueba a un contrato inteligente o dirección de cartera para que pueda realizar la transferencia de la propiedad del token.
      * @param to Dirección aprobada
     */
    function approve(address to) external {
        require(to != _owner, "No es posible aprobar al propietario");
        require(msg.sender == _owner,
            "No eres propietario"
        );

        _approve(to);
    }

    /** 
      * transfer(address to)
      * @notice Transfiere la propiedad del token a un nuevo propietario
      * @param to Dirección del nuevo propietario
     */
     function transfer(
        address to
    ) external {
        require(
            _isApprovedOrOwner(msg.sender),
            "No estas aprobado sobre el token"
        );

        _transfer(_owner, to);
    }

    /** 
      * isCallerApproved()
      * @notice Informa si el solicitante esta aprobado para la transferencia de la propiedad del token.
     */
    function isCallerApproved() external view returns (bool){
        return _isApprovedOrOwner(msg.sender);
    }


    function _isApprovedOrOwner(address spender) internal view returns (bool) {
        return (spender == _owner || spender == _tokenApproval);
    }

    function _approve(address to) internal {
        _tokenApproval = to;
        emit Approval(_owner, to);
    }

    function _transfer(
        address from,
        address to
    ) internal {
        require(_owner == from, "No eres propietario del token");
        require(to != address(0), "No se puede transferir a la burn address");

        _owner = to;

        emit Transfer(from, to);
    }
}
