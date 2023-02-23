const { ethers } = require("hardhat");

async function main() {
    const AuctionFactoryC = await ethers.getContractFactory("AuctionFactoryC");
    const auctionFactory = await AuctionFactoryC.deploy("0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199");
    await auctionFactory.deployed();

    const [addr1, addr2, addr3] = await ethers.getSigners()
    console.log("Auction Factory address: " + auctionFactory.address)

    await auctionFactory.connect(addr2).register()
    await auctionFactory.connect(addr3).register()

    const auctioneers = await auctionFactory.allAuctioneers();
    console.log(auctioneers);

    const zkProxy = await auctionFactory.connect(addr2).createAuction();
    console.log(zkProxy);

    const proxies = await auctionFactory.allAuctionProxies();
    console.log(proxies);

    
    const zkProxyP = await ethers.getContractFactory('zkVickreyAuctionC')
    const zkProxyC = await zkProxyP.attach(zkProxy.toString())
    const testI = zkProxyC.testImplementation();
    console.log(testI);
    
}


main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
