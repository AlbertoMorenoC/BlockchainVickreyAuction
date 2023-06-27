import fs from 'fs';
const { ethers } = require("hardhat");

async function main() {

    
    const AuctionFactoryC = await ethers.getContractFactory("AuctionFactoryC");
    const [addr1, addr2, addr3, addr4] = await ethers.getSigners()
    const auctionFactory = await AuctionFactoryC.deploy(addr1.address);
    await auctionFactory.deployed();

    console.log(auctionFactory);


   
    //const auctionFactory = await AuctionFactoryC.deploy(addr1.address);

    interface Auction {
        name: string;
        addr: string;  
    }

    const auctions : Auction [] = [];

    function delay(ms: number) {
        return new Promise((resolve) => setTimeout(resolve, ms));
    }

    /*CREATON OF SOME AUCTIONS*/
    /*
    //Listen for Auction Created events
    auctionFactory.on('AuctionCreated',(name: string, address: string) => {
        console.log('Event received:');
        console.log('Nombre :', name);    
        console.log('Direccion :', address);
        auctions.push({name:name,addr:address})
        console.log(auctions)
    });


    console.log("Auction Factory address: " + auctionFactory.address)
    console.log("Type of factory: " + typeof(auctionFactory))

    await auctionFactory.connect(addr2).register()
    await auctionFactory.connect(addr3).register()

    const auctionsPrev= await auctionFactory.allAuctions();
    console.log("Prev auctions: " + auctionsPrev);

    await auctionFactory.connect(addr2).createAuction("Ferrari",addr2.address,300,0,0,10,"subasta2.com","0x5FbDB2315678afecb367f032d93F642f64180aa3");
    console.log("direccion cartera 2: ", addr2.address)
    const auctionsPost = await auctionFactory.allAuctions();
    console.log("Post auctions: " + auctionsPost);
    
    //Wait until addresses of proxies get registered
    await delay(5000);
    
    const abiP = './artifacts/contracts/implementation/zkVickreyAuction.sol/zkVickreyAuctionC.json'; 
    const abiA = fs.readFileSync(abiP, 'utf-8');
    const abiAuction = JSON.parse(abiA);
    const auctionProxy1 = new ethers.Contract(auctions[0].addr, abiAuction.abi);
    */
    /*auctionProxy1.on("AuctionMetadata", (time1: number, time2: number, time3: number) => {
        console.log('Event received:');
        console.log('Number1 : ', time1);    
        console.log('Number2 : ', time2);
        console.log('Number3 : ', time3);
    });

    await auctionProxy1.connect(addr1).testEvents();

    const events = await auctionProxy1.queryFilter("AuctionMetadata(uint256,uint256,uint256)");
    events.forEach((event) => {
        console.log(event.args); // Access event parameters
      });*/
    
    /*INTERACCION ARTIFICIAL POSTORES Y SUBASTAS*/
    //Registro de los usuarios en la primera subasta
    /*
    await auctionProxy1.connect(addr1).register();
    await auctionProxy1.connect(addr2).register();

    const resultRegsA1 = await auctionProxy1.connect(addr2).testRegistered();
    console.log("Registros en A1: " + resultRegsA1);

    const auctionProxy2 = new ethers.Contract(auctions[1].addr, abiAuction.abi);
    
    //Registro de los usuarios en la segunda subasta
    await auctionProxy2.connect(addr1).register();
    await auctionProxy2.connect(addr2).register();
    await auctionProxy2.connect(addr3).register();
    await auctionProxy2.connect(addr4).register();

    const resultRegsA2 = await auctionProxy2.connect(addr2).testRegistered();
    console.log("Registros en A2: " + resultRegsA2);
    
    //Commit en la primera subasta
    const commit1 = await auctionProxy1.connect(addr1).commit(2,ethers.utils.parseUnits("100","ether"));
    console.log("Commit1 sobre Subasta1: " + commit1);
    
    //Puja con el commit anterior en la primera subasta
    const minFee = 300
    const transCommit = await auctionProxy1.connect(addr1).bid(commit1.c1,commit1.c2,commit1.c3,{value: minFee});
    await transCommit.wait()

    const actualCommits1 = await auctionProxy1.connect(addr1).testCommited();
    console.log("Commits registrados 1: " + actualCommits1)

    const transVerify = await auctionProxy1.connect(addr1).verify(2,ethers.utils.parseUnits("100","ether"),{value: ethers.utils.parseUnits("100","ether")});
    await transVerify.wait()

    const actualCommits2 = await auctionProxy1.connect(addr1).testCommited();
    console.log("Commits registrados 2: " + actualCommits2)

    const verification = await auctionProxy1.connect(addr1).testVerification();
    console.log("Compara verificacion: " + verification)*/

    //const ownership1 = await auctionProxy1.connect(addr1).claimReward();


    /*
    const codeAt = await ethers.provider.getCode(auctionFactory.address)
    console.log("Generador_subastas: " + auctionFactory.address)
    console.log("Codigo de generador_subastas: " +  codeAt)
    const zkProxyP = await ethers.getContractFactory('zkVickreyAuctionC')
    const zkProxyC = await zkProxyP.attach(zkProxy.toString())
    const testI = zkProxyC.testImplementation();
    console.log(testI);*/
    
}


main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
