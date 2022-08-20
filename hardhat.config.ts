import "@nomicfoundation/hardhat-toolbox";
import { config as dotenvConfig } from "dotenv";
import type { HardhatUserConfig } from "hardhat/config";
import type { NetworkUserConfig } from "hardhat/types";
import { resolve } from "path";

import { default as api_keys } from "./api_keys.json";
import "./tasks/accounts";
import "./tasks/deploy";

const dotenvConfigPath: string = process.env.DOTENV_CONFIG_PATH || "./.env";
dotenvConfig({ path: resolve(__dirname, dotenvConfigPath) });

// Ensure that we have all the environment variables we need.
const mnemonic: string | undefined = process.env.MNEMONIC;
if (!mnemonic) {
  throw new Error("Please set your MNEMONIC in a .env file");
}

const chainIds = {
  "arbitrum-mainnet": 42161,
  hardhat: 31337,
  "eth-mainnet": 1,
  "avalanche-mainnet": 43114,
  "bsc-mainnet": 56,
  "klaytn-mainnet": 8217,
  "celo-mainnet": 42220,
  "aurora-mainnet": 1313161554,
  "optimism-mainnet": 10,
  "polygon-mainnet": 137,
  "polygon-mumbai": 80001,
  rinkeby: 4,
};

function getChainConfig(chain: string): NetworkUserConfig {
  let jsonRpcUrl: string | undefined;
  let apiKey: string | undefined;
  switch (chain) {
    case "eth-mainnet" ||
      "avalanche-mainnet" ||
      "bsc-mainnet" ||
      "klaytn-mainnet" ||
      "celo-mainnet" ||
      "aurora-mainnet" ||
      "polygon-mainnet":
      jsonRpcUrl = api_keys[chain].jsonRpcUrl;
      apiKey = api_keys[chain].API_Key;
      break;

    default:
      throw new Error("No chain description in a api_keys file");
  }

  if (!apiKey) {
    throw new Error("Please set your API_KEY in a api_keys file");
  }
  jsonRpcUrl = jsonRpcUrl + "/" + apiKey;

  return {
    accounts: {
      count: 10,
      mnemonic,
      path: "m/44'/60'/0'/0",
    },
    chainId: chainIds[chain],
    url: jsonRpcUrl,
  };
}

const config: HardhatUserConfig = {
  defaultNetwork: "hardhat",
  etherscan: {
    apiKey: {
      avalanche: process.env.SNOWTRACE_API_KEY || "",
      bsc: process.env.BSCSCAN_API_KEY || "",
      mainnet: process.env.ETHERSCAN_API_KEY || "",
      optimisticEthereum: process.env.OPTIMISM_API_KEY || "",
      polygon: process.env.POLYGONSCAN_API_KEY || "",
      polygonMumbai: process.env.POLYGONSCAN_API_KEY || "",
      rinkeby: process.env.ETHERSCAN_API_KEY || "",
    },
  },
  gasReporter: {
    currency: "USD",
    enabled: process.env.REPORT_GAS ? true : false,
    excludeContracts: [],
    src: "./contracts",
  },
  networks: {
    hardhat: {
      accounts: {
        mnemonic,
      },
      chainId: chainIds.hardhat,
    },
    celo: getChainConfig("celo-mainnet"),
    aurora: getChainConfig("aurora-mainnet"),
    klaytn: getChainConfig("klaytn-mainnet"),
    avalanche: getChainConfig("avalanche-mainnet"),
    bsc: getChainConfig("bsc-mainnet"),
    eth: getChainConfig("eth-mainnet"),
    "polygon-mainnet": getChainConfig("polygon-mainnet"),
    "polygon-mumbai": getChainConfig("polygon-mumbai"),
    rinkeby: getChainConfig("rinkeby"),
  },
  paths: {
    artifacts: "./artifacts",
    cache: "./cache",
    sources: "./contracts",
    tests: "./test",
  },
  solidity: {
    version: "0.8.15",
    settings: {
      metadata: {
        // Not including the metadata hash
        // https://github.com/paulrberg/hardhat-template/issues/31
        bytecodeHash: "none",
      },
      // Disable the optimizer when debugging
      // https://hardhat.org/hardhat-network/#solidity-optimizer-support
      optimizer: {
        enabled: true,
        runs: 1200,
      },
    },
  },
  typechain: {
    outDir: "src/types",
    target: "ethers-v5",
  },
};

export default config;
