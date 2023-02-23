// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;


contract ElipticCurveToolsC {

    //Prime number on which the field of the curve is defined
    uint256 public p = uint256(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F);
    //Order of the curve (number of points)
    uint256 public n = uint256(0xfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141);
    //Generator point G
    uint256 public Gx = uint256(0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798);
    uint256 public Gy = uint256(0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8);
    //Generator point H = SHA256(G*88007)
    uint256 public Hx = uint256(0xebd39f73fc732204e5123f646ec73d2dae67154d1a67a593c65ea8c97dd1c5f4);
    uint256 public Hy = uint256(0x30fb036d3d825fe98dfc416fa5333c48c105747deb749532eae09be85ff63dbe);
    //Subgroup cofactor
    uint public h1 = 1;
    //Curve coefficients 
    uint public a = 0;
    uint public b = 7;

    function invMod(uint256 _x) internal view returns (uint256) {
        require(_x != 0 && _x != p && p != 0, "Invalid number");

        uint256 q = 0;
        uint256 newT = 1;
        uint256 r = p;
        uint256 t;

        while (_x != 0) {
            t = r / _x;
            (q, newT) = (newT, addmod(q, (p - mulmod(t, newT, p)), p));
            (r, _x) = (_x, r - t * _x);
        }

        return q;
    }

    function toNon_Jacobi(uint256 _x,uint256 _y,uint256 _z) internal view returns (uint256 x1, uint256 y1)
    {
        uint inv_z = invMod(_z);
        uint inv_z2 = mulmod(inv_z, inv_z, p);
        uint inv_z3 = mulmod(inv_z, inv_z2, p);
        x1 = mulmod(_x, inv_z2, p);
        y1 = mulmod(_y, inv_z3, p);
    }

    function toJacobi(uint256 _x, uint256 _y) internal pure returns (uint256 x1, uint256 y1, uint256 z1){

        return (_x,_y,1);

    }

    function cAdd(uint256 _x1, uint256 _y1, uint256 _x2, uint256 _y2,uint256 _z1, uint256 _z2) internal view returns (uint256 x1, uint256 y1, uint256 z1)
    { 
        //Check trivial sum
        if ((_x1==0)&&(_y1==0)) return (_x2, _y2, _z2);
        if ((_x2==0)&&(_y2==0)) return (_x1, _y1, _z1);

        //Compute auxiliar Zs
        uint z1p2 = mulmod(_z1,_z1,p);
        uint z1p3 = mulmod(_z1,z1p2,p);
        uint z2p2 = mulmod(_z2,_z2,p);
        uint z2p3 = mulmod(_z2,z2p2,p); 

        //Compute auxiliar A,B,c,d
        uint A = mulmod(_x1,z2p2,p);
        uint B = addmod(mulmod(_x2,z1p2,p),p-A,p);
        uint c = mulmod(_y1,z2p3,p);
        uint d = addmod(mulmod(_y2,z1p3,p),p-c,p);

        //Compute result point x3,y3,z3 (info: Bernstein formulas use aux variables to organize computations)
        uint e = mulmod(B,B,p);
        uint f = mulmod(B,e,p);
        uint g = mulmod(A,e,p);
        uint h = mulmod(_z1,_z2,p);
        uint f2g = addmod(mulmod(2,g,p),f,p);
        uint X3 = addmod(mulmod(d,d,p),p-f2g,p);
        uint Z3 = mulmod(B,h,p);
        uint gx = addmod(g,p-X3,p);
        uint cf = mulmod(c,f,p);
        uint Y3 = addmod(mulmod(d,gx,p),p-cf,p);

        return(X3,Y3,Z3);
    }

    function cDouble(uint256 _x1, uint256 _y1, uint256 _z1) internal view returns (uint256 x1, uint256 y1, uint256 z1)
    {
        //Check trivial double
        if(_x1==0 && _y1==0) return(_x1,_y1,_z1);

        //Compute auxiliar variables to get S and M
        uint y1p2 = mulmod(_y1,_y1,p);
        uint S = mulmod(4,mulmod(_x1,y1p2,p),p);

        uint x1p2 = mulmod(_x1,_x1,p);
        uint z1p2 = mulmod(_z1,_z1,p);
        uint z1p4 = mulmod(z1p2,z1p2,p);
        uint m1 = mulmod(3,x1p2,p);
        //Maybe this operation is not needed -> a=0 for our ec
        uint m2 = mulmod(a, z1p4,p);
        uint M = addmod(m1,m2,p);
        
        //Compute aux variables to get final point
        uint Mp2 = mulmod(M,M,p);
        uint s2 = mulmod(2,S,p);
        uint yz = mulmod(_y1,_z1,p);
        uint X = addmod(Mp2,p-s2,p);
        uint MSX = mulmod(M, addmod(S,p-X,p),p);
        uint y1p4 = mulmod(y1p2,y1p2,p);
        uint y8p4 = mulmod(8,y1p4,p);
        uint Y = addmod(MSX, p-y8p4,p);
        uint Z = mulmod(2,yz,p);
        
        return(X,Y,Z);

    }

    function cMult (uint256 _x1, uint256 _y1, uint256 _z1, uint256 _v) internal view returns (uint256 x1, uint256 y1, uint256 z1){

        //Check trivial mult
        if(_v==0) return(0,0,1);

        uint256 v_upd = _v;
        uint256 Rx = _x1;
        uint256 Ry = _y1;
        uint256 Rz = _z1;  
        uint256 Qx = 0;
        uint256 Qy = 0;
        uint256 Qz = 1;

        //Compute non-trivial case using double and add algorithm
        while(v_upd != 0) {
            if((v_upd & 1) != 0){
                (Qx,Qy,Qz) = cAdd(Qx,Qy,Qz,Rx,Ry,Rz);
            }
            v_upd = v_upd >> 1;
            (Rx,Ry,Rz) = cDouble(Rx,Ry,Rz);
        }

        return (Qx,Qy,Qz);

    }
}