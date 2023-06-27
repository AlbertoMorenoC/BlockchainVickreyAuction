// Importar la biblioteca web3.js
//import Web3 from 'web3';
/*
const provider = new Web3.providers.WebsocketProvider("ws://localhost:8545")
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
const direccionContrato = contractAddress; // Reemplazar con la dirección de tu contrato
const abiContrato = [
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "address[]",
        "name": "registers",
        "type": "address[]"
      }
    ],
    "name": "ActualRegisters",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "components": [
          {
            "internalType": "uint256",
            "name": "c1",
            "type": "uint256"
          },
          {
            "internalType": "uint256",
            "name": "c2",
            "type": "uint256"
          },
          {
            "internalType": "uint256",
            "name": "c3",
            "type": "uint256"
          }
        ],
        "indexed": false,
        "internalType": "struct zkVickreyAuctionC.Commit[]",
        "name": "commits",
        "type": "tuple[]"
      }
    ],
    "name": "AuctionCommits",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "b_p",
        "type": "uint256"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "r_p",
        "type": "uint256"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "min_f",
        "type": "uint256"
      }
    ],
    "name": "AuctionMetadata",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "bytes32[]",
        "name": "verifications",
        "type": "bytes32[]"
      }
    ],
    "name": "AuctionVerification",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "components": [
          {
            "internalType": "uint256",
            "name": "c1",
            "type": "uint256"
          },
          {
            "internalType": "uint256",
            "name": "c2",
            "type": "uint256"
          },
          {
            "internalType": "uint256",
            "name": "c3",
            "type": "uint256"
          }
        ],
        "indexed": false,
        "internalType": "struct zkVickreyAuctionC.Commit",
        "name": "commit",
        "type": "tuple"
      }
    ],
    "name": "CommitEvent",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "uint8",
        "name": "version",
        "type": "uint8"
      }
    ],
    "name": "Initialized",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "bool",
        "name": "isWinner",
        "type": "bool"
      }
    ],
    "name": "isBidderWinner",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "bool",
        "name": "verified",
        "type": "bool"
      }
    ],
    "name": "isCommitVerified",
    "type": "event"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "c1",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "c2",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "c3",
        "type": "uint256"
      }
    ],
    "name": "bid",
    "outputs": [],
    "stateMutability": "payable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "claimReward",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "_r",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "_m",
        "type": "uint256"
      }
    ],
    "name": "commit",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "c1",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "c2",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "c3",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "_r",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "_m",
        "type": "uint256"
      }
    ],
    "name": "commitWithEvent",
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
    "name": "commits",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "c1",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "c2",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "c3",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "getMetadata",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
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
        "name": "_open_time",
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
        "name": "_factory_address",
        "type": "address"
      },
      {
        "internalType": "address",
        "name": "_token_address",
        "type": "address"
      }
    ],
    "name": "initialize",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "register",
    "outputs": [
      {
        "internalType": "bool",
        "name": "",
        "type": "bool"
      }
    ],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "testCommited",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "testRegistered",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "testVerification",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "_r",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "_m",
        "type": "uint256"
      }
    ],
    "name": "verify",
    "outputs": [],
    "stateMutability": "payable",
    "type": "function"
  }
]// Reemplazar con el ABI de tu contrato

// Crear una instancia del contrato
const contrato = new web3.eth.Contract(abiContrato, direccionContrato);

//Recibir metadata de la subasta
const recibirMetadata = async () => {
  const cuenta = await obtenerCuenta();
  await contrato.methods.getMetadata().send({ from: cuenta });
  const eventAuctionMetadata = await contrato.getPastEvents("AuctionMetadata");
  const eventArgs = eventAuctionMetadata[0]; // Event parameters as an object
  // Do something with the event data
  const dateTimeValues = [];
  for (i = 0; i < 3; i++) {
    const milliseconds = eventArgs.returnValues[i] * 1000; // Convert seconds to milliseconds
    const date = new Date(milliseconds);

    const day = date.getDate();
    const month = date.getMonth() + 1; // Months are zero-based, so add 1
    const year = date.getFullYear();
    const hour = date.getHours();
    var minutes = date.getMinutes();
    if (minutes < 10) minutes = "0" + minutes
    dateTimeValues.push(`${day}/${month}/${year} ${hour}:${minutes}`);
  }
  console.log(dateTimeValues)
  console.log(eventAuctionMetadata[0].returnValues)
  return dateTimeValues;
};

const setTimeAuctionMetadata = async () => {
  const dateTimeVals = await recibirMetadata();
  const verificacionItem = document.getElementById("verificacion");
  verificacionItem.textContent = dateTimeVals[0];
  const reclamoItem = document.getElementById("reclamo-recompensa");
  reclamoItem.textContent = dateTimeVals[1];
}

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


const llamarRegistro = async () => {
  const cuenta = await obtenerCuenta();
  await contrato.methods.register().send({ from: cuenta });
  console.log('Función testRegistros llamada');
};


const llamarCommit = async () => {
  const cuenta = await obtenerCuenta();
  const rC = document.getElementById("rC").value;
  const mC = document.getElementById("mC").value;
  const commitEvent = await contrato.methods.commitWithEvent(rC, web3.utils.toWei(mC)).send({ from: cuenta });
  console.log('Función commit llamada');
  const commit = commitEvent.events.CommitEvent.returnValues[0]
  document.getElementById("c1G").value = commit.c1
  document.getElementById("c2G").value = commit.c2
  document.getElementById("c3G").value = commit.c3
};


const llamarPuja = async () => {
  const cuenta = await obtenerCuenta();
  await contrato.methods.getMetadata().send({ from: cuenta });
  const eventAuctionMetadataTotal = await contrato.getPastEvents("AuctionMetadata");
  const eventAuctionMetadata = eventAuctionMetadataTotal[0];
  const min_fee = eventAuctionMetadata.returnValues[2];
  console.log("MinFee: ", min_fee)
  const c1 = document.getElementById("c1").value;
  const c2 = document.getElementById("c2").value;
  const c3 = document.getElementById("c3").value;
  console.log(c1, c2, c3)
  await contrato.methods.bid(web3.utils.toHex(c1), web3.utils.toHex(c2), web3.utils.toHex(c3)).send({ from: cuenta, value: min_fee });
  await contrato.methods.testCommited().send({ from: cuenta })
  const eventAuctionCommits = await contrato.getPastEvents("AuctionCommits");
  console.log('Función subasta llamada');
  console.log(eventAuctionCommits);
};

// Función para llamar a la función 'verificar' del contrato
const llamarVerificar = async () => {
  const cuenta = await obtenerCuenta();
  const rV = document.getElementById("rV").value;
  const mV = document.getElementById("mV").value;
  const verificationtx = await contrato.methods.verify(rV, web3.utils.toWei(mV)).send({ from: cuenta, value: web3.utils.toWei(mV) });
  await contrato.methods.testVerification().send({ from: cuenta })
  console.log(verificationtx)
  const eventAuctionVerify = await contrato.getPastEvents("AuctionVerification");
  console.log(eventAuctionVerify);
  console.log('Función verificar llamada');
};

// Función para llamar a la función 'recompensa' del contrato
const llamarRecompensa = async () => {
  const cuenta = await obtenerCuenta();
  await contrato.methods.claimReward().send({ from: cuenta });
  console.log('Función recompensa llamada');
};

