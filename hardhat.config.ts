import { HardhatUserConfig } from "hardhat/config"
import "@nomicfoundation/hardhat-toolbox"

const PRIVATE_KEY = process.env.PRIVATE_KEY
const config: HardhatUserConfig = {
    defaultNetwork: "hardhat",
    networks: {
        hardhat: {
            chainId: 31337,
        },
        localhost: {
            chainId: 31337,
        },
        sonic: {
            url: process.env.SONIC_RPC_URL || "https://rpc.soniclabs.com",
            accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
            chainId: 146,
        },
    },
    solidity: "0.8.28",
}

export default config
