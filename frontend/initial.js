
/*const provider = new Web3.providers.HttpProvider("https://rpc2.sepolia.org")
const web3 = new Web3(provider);

// Obtener la cuenta actualmente seleccionada en MetaMask
const obtenerCuenta = async () => {
  await window.ethereum.request({ method: 'eth_requestAccounts' });
  const cuentas = await web3.eth.getAccounts();
  console.log("Cuentas obtenidas: " + cuentas);
  return cuentas[10];
};*/

// Check if MetaMask is installed
if (typeof web3 !== 'undefined') {
  // Use MetaMask's provider
  web3 = new Web3(web3.currentProvider);
} else {
  // Handle the case where MetaMask is not installed
  console.log("Please install MetaMask");
}

// Request account access if needed
const obtenerCuenta = async () => {
  const cuentas = await web3.eth.requestAccounts();
  console.log("Cuenta actual: "+ cuentas[0]);
  return cuentas[0];
}
// Dirección del contrato y su ABI
const direccionContrato = "0x30F6Efc36323fC53D43eB80325B074dC8bBa47cf"; // Reemplazar con la dirección de tu contrato
const abiContrato = [
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "_beaconOwner",
        "type": "address"
      }
    ],
    "stateMutability": "nonpayable",
    "type": "constructor"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "string",
        "name": "name",
        "type": "string"
      },
      {
        "indexed": true,
        "internalType": "address",
        "name": "addr",
        "type": "address"
      }
    ],
    "name": "AuctionCreated",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "address",
        "name": "implementation",
        "type": "address"
      }
    ],
    "name": "Upgraded",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "address",
        "name": "adrr",
        "type": "address"
      }
    ],
    "name": "senderEvent",
    "type": "event"
  },
  {
    "inputs": [],
    "name": "allAuctions",
    "outputs": [
      {
        "components": [
          {
            "internalType": "uint256",
            "name": "auction_id",
            "type": "uint256"
          },
          {
            "internalType": "string",
            "name": "name",
            "type": "string"
          },
          {
            "internalType": "address",
            "name": "owner_address",
            "type": "address"
          },
          {
            "internalType": "address",
            "name": "auction_proxy",
            "type": "address"
          },
          {
            "internalType": "string",
            "name": "url",
            "type": "string"
          }
        ],
        "internalType": "struct AuctionFactoryC.Auction[]",
        "name": "",
        "type": "tuple[]"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "",
        "type": "address"
      }
    ],
    "name": "auctionProxies",
    "outputs": [
      {
        "internalType": "bool",
        "name": "",
        "type": "bool"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "",
        "type": "address"
      }
    ],
    "name": "auctioneers",
    "outputs": [
      {
        "internalType": "bool",
        "name": "",
        "type": "bool"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "bidder",
        "type": "address"
      }
    ],
    "name": "banBidder",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "",
        "type": "address"
      }
    ],
    "name": "bannedBidders",
    "outputs": [
      {
        "internalType": "bool",
        "name": "",
        "type": "bool"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "implementation",
        "type": "address"
      }
    ],
    "name": "changeBeaconImplementation",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "string",
        "name": "name",
        "type": "string"
      },
      {
        "internalType": "address",
        "name": "_owner_address",
        "type": "address"
      },
      {
        "internalType": "uint256",
        "name": "_min_fee",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "_bid_period",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "_reveal_period",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "_max_bidders",
        "type": "uint256"
      },
      {
        "internalType": "string",
        "name": "_url",
        "type": "string"
      },
      {
        "internalType": "address",
        "name": "_token_address",
        "type": "address"
      }
    ],
    "name": "createAuction",
    "outputs": [
      {
        "internalType": "address",
        "name": "",
        "type": "address"
      }
    ],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "bidder",
        "type": "address"
      }
    ],
    "name": "isBidderBanned",
    "outputs": [
      {
        "internalType": "bool",
        "name": "",
        "type": "bool"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "logicContract",
    "outputs": [
      {
        "internalType": "address",
        "name": "",
        "type": "address"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "register",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  }
]// Reemplazar con el ABI de tu contrato

// Crear una instancia del contrato
const contrato = new web3.eth.Contract(abiContrato, direccionContrato);

//Recibir metadata de la subasta
/*const recibirMetadata = async() => {
  const cuenta = await obtenerCuenta();
  const registros = await contrato.methods.getMetadata().send({ from: cuenta });
  const eventAuctionMetadata = await contrato.getPastEvents("AuctionMetadata");
  eventAuctionMetadata.forEach(event => {
    // Accessing event properties
    const eventName = event.event; // Name of the event
    const eventArgs = event[0]; // Event parameters as an object
  
    // Accessing specific properties from the event parameters
    const parameter1 = event.returnValues.open_time
    const parameter2 = event.returnValues.bid_period
    const parameter3 = event.returnValues.reveal_period
    // Do something with the event data
    console.log(eventName, parameter1, parameter2, parameter3);
  });
};*/

// Testing interacción con el contrato
const testRegistros = async () => {
  const cuenta = await obtenerCuenta();
  const registros = await contrato.methods.testRegistered().send({ from: cuenta });
  console.log('Función test registros llamada');
  const eventRegisters = await contrato.getPastEvents("ActualRegisters")
  const eventRegistersEvent = eventRegisters[0];
  const eventRegistersValues = eventRegistersEvent.returnValues.registers
  console.log(eventRegistersEvent.event, eventRegistersValues)
};

// Función para llamar a la función 'subasta' del contrato
const llamarRegistro = async () => {
  const cuenta = await obtenerCuenta();
  await contrato.methods.register().send({ from: cuenta });
  console.log('Función registro llamada');
};

// Función para llamar a la función 'subasta' del contrato
const llamarTodasSubastas = async () => {
  const cuenta = await obtenerCuenta();
  const auctions = await contrato.methods.allAuctions().call({ from: cuenta });
  //console.log(auctions)
  console.log('Función lista subastas');
  return auctions;
};

const executeTodasSubastas = async (tabla) => {
  const infoSubastas = await llamarTodasSubastas();
  console.log("TODAS LAS SUBASTAS: ", infoSubastas)
  for (i = 0; i < infoSubastas.length; i++) {
    const row = document.createElement("tr");
    var cellToClick;
    const subastaActual = infoSubastas[i];
    console.log("SUBASTA NUM ", i, subastaActual)
    const detailedInfoS = subastaActual.slice(1, 5);
    console.log("SUBASTA FORMAT NUM ", i, detailedInfoS)
    // Create table cells for each property in the element
    for (o = 0; o < detailedInfoS.length; o++) {
      const cell = document.createElement("td");
      if(o==0) cellToClick=cell;
      if(o==detailedInfoS.length-1) {
        const link = document.createElement("a");
        link.href=detailedInfoS[o]
        link.textContent="Info aqui"
        cell.appendChild(link)
      }else cell.textContent = detailedInfoS[o];
      row.appendChild(cell);
    }
    row.id = detailedInfoS[0];
    cellToClick.onclick = function () {
      redirectToSubasta(row.id);
    };
    tabla.appendChild(row);
  }
}


const llamarCrearSubasta = async (nombreArticulo, tasaMinima, inicioPujas, aperturaPujas, maximosPostores, urlInformativa, tokenDireccion) => {
  const cuenta = await obtenerCuenta();
  console.log(cuenta, nombreArticulo, parseInt(tasaMinima), parseInt(inicioPujas), parseInt(aperturaPujas), parseInt(maximosPostores), urlInformativa,tokenDireccion);
  const auction = await contrato.methods.createAuction(nombreArticulo, cuenta, web3.utils.toWei(tasaMinima), inicioPujas, aperturaPujas, maximosPostores, urlInformativa,tokenDireccion).send({ from: cuenta });
  console.log(auction)
  console.log('Función crear subasta');
};


const redirectToSubasta = async (row_id) => {
  const cuenta = await obtenerCuenta();
  const isBanned = await contrato.methods.isBidderBanned(cuenta).call({ from: cuenta });
  const actualRow = document.getElementById(row_id);
  //Comprobar si esta baneado
  console.log(isBanned)
  if (!isBanned) {
    var url = "subasta.html?address=" + encodeURIComponent(actualRow.cells[2].textContent) + "&name=" + encodeURIComponent(actualRow.cells[0].textContent);
    window.location.href = url;
  } else {
    alert("Estas BANEADO de la plataforma")
  }
}
