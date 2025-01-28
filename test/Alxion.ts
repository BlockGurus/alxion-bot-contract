import { time, loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers"
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs"
import { expect } from "chai"
import hre from "hardhat"
import { ethers } from "hardhat"
import fs from "fs"
import path from "path"
import dotenv from "dotenv"
dotenv.config()

console.log(process.env.PRIVATE_KEY)

describe("AlxionDeployer", function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.
    async function deployAlxionDeployerFixture() {
        // Contracts are deployed using the first signer/account by default
        const [owner, otherAccount] = await hre.ethers.getSigners()

        const AlxionDeployer = await hre.ethers.getContractFactory("AlxionDeployer")
        const botWallet = new ethers.Wallet(process.env.PRIVATE_KEY!)
        const alxionDeployer = await AlxionDeployer.deploy(botWallet.address)

        const alxionDeployerTokenAddress = await alxionDeployer.alxionToken()

        const abiPath = path.resolve(
            __dirname,
            "../artifacts/contracts/AlxionToken.sol/AlxionToken.json"
        )

        const alxionTokenInfo = JSON.parse(fs.readFileSync(abiPath, "utf-8"))

        const alxionToken = new ethers.Contract(
            alxionDeployerTokenAddress,
            alxionTokenInfo.abi,
            owner
        )

        return { alxionDeployer, alxionToken, owner, otherAccount }
    }

    describe("Deployment", function () {
        it("Should create a ERC20 token", async function () {
            const { alxionToken } = await loadFixture(deployAlxionDeployerFixture)

            expect(await alxionToken.name()).to.equal("AlxionToken")
            expect(await alxionToken.symbol()).to.equal("AXT")
            expect(await alxionToken.decimals()).to.equal(18)
        })
    })

    describe("Withdrawals", function () {
        describe("Validations", function () {
            it("Should revert if called by a non-bot address", async function () {
                const { alxionDeployer, otherAccount } = await loadFixture(
                    deployAlxionDeployerFixture
                )
                await expect(
                    alxionDeployer.updateBotAddress(otherAccount.address)
                ).to.be.revertedWithCustomError(alxionDeployer, "AlxionDeployer__Unauthorized")
            })
        })

        describe("Events", function () {
            it("Should emit an event on bot address update", async function () {
                const { alxionDeployer, otherAccount, owner } = await loadFixture(
                    deployAlxionDeployerFixture
                )

                const botSigner = new ethers.Wallet(process.env.PRIVATE_KEY!, ethers.provider)

                const tx = await owner.sendTransaction({
                    to: botSigner.address,
                    value: ethers.parseEther("1"),
                })

                await tx.wait()

                await expect(
                    alxionDeployer.connect(botSigner).updateBotAddress(otherAccount.address)
                )
                    .to.emit(alxionDeployer, "BotAddressUpdated")
                    .withArgs(botSigner.address, otherAccount.address)
            })
        })

        describe("Transfers", function () {
            it("Should be able to redeem points", async function () {
                const { alxionToken, alxionDeployer, owner } = await loadFixture(
                    deployAlxionDeployerFixture
                )
                await expect(alxionDeployer.redeemCode(1000)).to.changeTokenBalance(
                    alxionToken,
                    owner,
                    1000
                )
            })
        })
    })
})
