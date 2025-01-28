// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules"
import { ethers } from "hardhat"
import dotenv from "dotenv"
dotenv.config()
const alxionModule = buildModule("AlxionModule", (m) => {
    const botWallet = new ethers.Wallet(process.env.PRIVATE_KEY!)
    const alxionDeployer = m.contract("AlxionDeployer", [botWallet.address])
    return { alxionDeployer }
})

export default alxionModule
