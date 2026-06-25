import { JsonRpcProvider, Contract } from "ethers";

// ==========================================
// CONFIGURAZIONE MAGIC CONTAINER
// ==========================================
// Si connette al nodo Helios che gira nello STESSO container
const LOCAL_RPC_URL = "http://127.0.0.1:8545"; 

// SOSTITUISCI QUESTO CON L'IP DEL TUO SERVER LINUX
const CENTRAL_SERVER_URL = "http://84.247.134.22:3000/ingest/pool";

// Genera un ID univoco per questo container all'avvio
const CONTAINER_ID = "bunny-node-" + Math.random().toString(36).substring(7);

// ==========================================
// COSTANTI UNISWAP V3
// ==========================================
const UNISWAP_V3_FACTORY = "0x1F98431c8aD98523631AE4a59f267346ea31F984";
const FACTORY_ABI = ["event PoolCreated(address indexed token0, address indexed token1, uint24 indexed fee, int24 tickSpacing, address pool)"];
const ERC20_ABI = [
  "function name() view returns (string)", 
  "function symbol() view returns (string)", 
  "function decimals() view returns (uint8)"
];

const tokenCache = new Map();

async function getTokenMetadata(address, provider) {
  if (tokenCache.has(address)) return tokenCache.get(address);
  
  const tokenContract = new Contract(address, ERC20_ABI, provider);
  try {
    const [name, symbol, decimals] = await Promise.all([
      tokenContract.name().catch(() => "Unknown"),
      tokenContract.symbol().catch(() => "UNK"),
      tokenContract.decimals().catch(() => 18)
    ]);
    const metadata = { address, name, symbol, decimals: Number(decimals) };
    tokenCache.set(address, metadata);
    return metadata;
  } catch (error) {
    return { address, name: "Unknown", symbol: "UNK", decimals: 18 };
  }
}

async function startMonitoring() {
  console.log(`[${CONTAINER_ID}] Attesa avvio nodo Helios locale...`);
  
  // Attendi che Helios sia pronto
  let provider;
  while (true) {
    try {
      provider = new JsonRpcProvider(LOCAL_RPC_URL);
      await provider.getBlockNumber();
      console.log(`[${CONTAINER_ID}] Connesso al nodo Helios locale!`);
      break;
    } catch (e) {
      await new Promise(r => setTimeout(r, 1000));
    }
  }

  const factoryContract = new Contract(UNISWAP_V3_FACTORY, FACTORY_ABI, provider);

  console.log(`[${CONTAINER_ID}] In ascolto su Uniswap V3 Factory...`);

  // Sottoscrizione agli eventi (tramite polling ultra-veloce su localhost)
  factoryContract.on("PoolCreated", async (token0, token1, fee, tickSpacing, pool, event) => {
    const detectionTimestamp = Date.now();
    
    const [token0Data, token1Data] = await Promise.all([
      getTokenMetadata(token0, provider),
      getTokenMetadata(token1, provider)
    ]);

    const payload = {
      timestamp: detectionTimestamp,
      blockNumber: event.log.blockNumber,
      transactionHash: event.log.transactionHash,
      poolAddress: pool,
      feeTier: Number(fee),
      token0: token0Data,
      token1: token1Data,
      dex: "Uniswap V3",
      containerId: CONTAINER_ID
    };

    console.log(`[${CONTAINER_ID}] Nuova pool rilevata! Invio al server centrale...`);

    // Invia i dati al server centrale
    fetch(CENTRAL_SERVER_URL, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload)
    }).catch(err => console.error("Errore invio al server:", err));
  });
}

startMonitoring();