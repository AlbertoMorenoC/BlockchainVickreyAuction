// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


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

    function name() external view returns (string memory) {
        return _name;
    }

    function metadata() external view returns (string memory) {
        return _metadata;
    }


    function ownerOfToken() external view returns (address) {
        return _owner;
    }

    function approve(address to) external {
        require(to != _owner, "No es posible aprobar al propietario");
        require(msg.sender == _owner,
            "No eres propietario"
        );

        _approve(to);
    }

     function transfer(
        address to
    ) external {
        require(
            _isApprovedOrOwner(msg.sender),
            "No estas aprobado sobre el token"
        );

        _transfer(_owner, to);
    }

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