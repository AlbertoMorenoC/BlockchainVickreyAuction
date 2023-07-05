// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

//dbl-1998-cmo-2: Bernstein Formulas
//LIBRERIA FUNCIONALIDAD CRIPTOGRÁFICA
library ECTools {

    //Orden primo sobre el que se define el grupo sobre el que se define la curva elíptica
    uint256 constant public p = uint256(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F);
    //Orden de la curva elíptica (Número de puntos que contiene)
    uint256 constant public n = uint256(0xfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141);
    //Punto generador G
    uint256 constant public Gx = uint256(0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798);
    uint256 constant public Gy = uint256(0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8);
    //Punto generador H = SHA256(G*88007)
    uint256 constant public Hx = uint256(0xebd39f73fc732204e5123f646ec73d2dae67154d1a67a593c65ea8c97dd1c5f4);
    uint256 constant public Hy = uint256(0x30fb036d3d825fe98dfc416fa5333c48c105747deb749532eae09be85ff63dbe);
    //Cofactor de subgrupo
    uint256 constant public h1 = 1;
    //Coeficientes de la curva elíptica
    uint256 constant public a = 0;
    uint256 constant public b = 7;


    /** 
      * invMod(uint256 _x)
      * @notice Calcula el inverso modular
      * @param _x Valor sobre el que se calcula el inverso
     */
    function invMod(uint256 _x) internal pure returns (uint256) {
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

    /** 
      * toNon_Jacobi(uint256 _x,uint256 _y,uint256 _z)
      * @notice Conversión de representación de coordenadas Jacobi a cartesianas
      * @param _x Coordenada x del punto dado
      * @param _y Coordenada y del punto dado
      * @param _z Coordenada z del punto dado
     */
    function toNon_Jacobi(uint256 _x,uint256 _y,uint256 _z) internal pure returns (uint256 x1, uint256 y1)
    {
        uint inv_z = invMod(_z);
        uint inv_z2 = mulmod(inv_z, inv_z, p);
        uint inv_z3 = mulmod(inv_z, inv_z2, p);
        x1 = mulmod(_x, inv_z2, p);
        y1 = mulmod(_y, inv_z3, p);

        return (x1,y1);
    }

    /** 
      * toJacobi(uint256 _x, uint256 _y)
      * @notice Conversión de representación de coordenadas cartesianas a Jacobi
      * @param _x Coordenada x del punto dado
      * @param _y Coordenada y del punto dado
     */
    function toJacobi(uint256 _x, uint256 _y) internal pure returns (uint256 x1, uint256 y1, uint256 z1){

        return (_x,_y,1);

    }

    /** 
      * cAdd(uint256 _x1, uint256 _y1, uint256 _x2, uint256 _y2,uint256 _z1, uint256 _z2)
      * @notice Suma de dos puntos 
      * @param _x1 Coordenada x del primer punto dado
      * @param _y1 Coordenada y del primer punto dado
      * @param _z1 Coordenada z del primer punto dado
      * @param _x2 Coordenada x del segundo punto dado
      * @param _y2 Coordenada y del segundo punto dado
      * @param _z2 Coordenada z del segundo punto dado
     */
    function cAdd(uint256 _x1, uint256 _y1, uint256 _x2, uint256 _y2,uint256 _z1, uint256 _z2) internal pure returns (uint256 x1, uint256 y1, uint256 z1)
    { 
        //Comprobar el caso trivial
        if ((_x1==0)&&(_y1==0)) return (_x2, _y2, _z2);
        if ((_x2==0)&&(_y2==0)) return (_x1, _y1, _z1);

       
        uint [4] memory zss;
        zss[0] = mulmod(_z1,_z1,p);  //zss[0]
        zss[1] = mulmod(_z1,zss[0],p); //zss[1]
        zss[2] = mulmod(_z2,_z2,p);  //zss[2]
        zss[3] = mulmod(_z2,zss[2],p); //zss[3]

        
        uint [4] memory const;
        const[0] = mulmod(_x1,zss[2],p); //A
        const[1] = addmod(mulmod(_x2,zss[0],p),p-const[0],p);//B
        const[2] = mulmod(_y1,zss[3],p);//c
        const[3] = addmod(mulmod(_y2,zss[1],p),p-const[2],p);//d

        
        uint e = mulmod(const[1],const[1],p);
        uint f = mulmod(const[1],e,p);
        uint g = mulmod(const[0],e,p);
        uint h = mulmod(_z1,_z2,p);
        uint f2g = addmod(mulmod(2,g,p),f,p);
        uint X3 = addmod(mulmod(const[3],const[3],p),p-f2g,p);
        uint Z3 = mulmod(const[1],h,p);
        uint gx = addmod(g,p-X3,p);
        uint cf = mulmod(const[2],f,p);
        uint Y3 = addmod(mulmod(const[3],gx,p),p-cf,p);

        return(X3,Y3,Z3);
    }

    /** 
      * cDouble(uint256 _x1, uint256 _y1, uint256 _z1)
      * @notice Doble de un punto dado
      * @param _x1 Coordenada x del punto dado
      * @param _y1 Coordenada y del punto dado
      * @param _z1 Coordenada z del punto dado
     */
    function cDouble(uint256 _x1, uint256 _y1, uint256 _z1) internal pure returns (uint256 x1, uint256 y1, uint256 z1)
    {
        //Comprobar el caso trivial
        if(_x1==0 && _y1==0) return(_x1,_y1,_z1);

        
        uint [4] memory aux_coords;
        aux_coords[0] = mulmod(_x1,_x1,p); //x1p2
        aux_coords[1] = mulmod(_y1,_y1,p); //y1p2
        aux_coords[2] = mulmod(_z1,_z1,p); //z1p2
        aux_coords[3] = mulmod(aux_coords[2],aux_coords[2],p); //z1p4
        uint m1 = mulmod(3,aux_coords[0],p);
        uint m2 = mulmod(a, aux_coords[3],p);
        uint S = mulmod(4,mulmod(_x1,aux_coords[1],p),p);
        uint M = addmod(m1,m2,p);
        
        
        uint [3] memory XYZ;
        uint Mp2 = mulmod(M,M,p);
        uint s2 = mulmod(2,S,p);
        uint yz = mulmod(_y1,_z1,p);
        XYZ[0] = addmod(Mp2,p-s2,p); //X
        uint MSX = mulmod(M, addmod(S,p-XYZ[0],p),p);
        uint y1p4 = mulmod(aux_coords[1],aux_coords[1],p);
        uint y8p4 = mulmod(8,y1p4,p);
        XYZ[1] = addmod(MSX, p-y8p4,p); //Y
        XYZ[2] = mulmod(2,yz,p); //Z
        
        return(XYZ[0],XYZ[1],XYZ[2]);

    }

    /** 
      * cMult(uint256 _x1, uint256 _y1, uint256 _z1, uint256 _v)
      * @notice Producto de un punto por un factor dado
      * @param _x1 Coordenada x del punto dado
      * @param _y1 Coordenada y del punto dado
      * @param _z1 Coordenada z del punto dado
      * @param _v Factor v del producto
     */
    function cMult (uint256 _x1, uint256 _y1, uint256 _z1, uint256 _v) internal pure returns (uint256 x1, uint256 y1, uint256 z1){

        //Comprobar el caso trivial
        if(_v==0) return(0,0,1);

        uint256 v_upd = _v;
        uint256 Rx = _x1;
        uint256 Ry = _y1;
        uint256 Rz = _z1;  
        uint256 Qx = 0;
        uint256 Qy = 0;
        uint256 Qz = 1;

        //Computar el caso no trivial haciendo uso de cAdd y cDouble
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
