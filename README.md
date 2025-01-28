# Alxion Contracts

Alxion is a decentralized platform built on the **Sonic S** network, designed to offer users the ability to interact with smart contracts and decentralized applications, while also providing various incentives for participating in its ecosystem.

## Requirements

- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
  - You'll know you did it right if you can run `git --version` and you see a response like `git version x.x.x`.
- [Node.js](https://nodejs.org/en/)
  - You'll know you've installed Node.js right if you can run:
    - `node --version` and get an output like `vx.x.x`.
- [Yarn](https://classic.yarnpkg.com/lang/en/docs/install/) instead of `npm`
  - You'll know you've installed Yarn right if you can run:
    - `yarn --version` and get an output like `x.x.x`.
    - You might need to install it with `npm`.

## Quickstart

```bash
git clone https://github.com/BlockGurus/alxion-bot-contract
cd alxion-bot-contract
yarn
```

## Usage

### Deploy:

```bash
yarn deploy
```

### Testing

```bash
yarn test
```

## Deployment to Sonic S Testnet

### 1. Setup Environment Variables

You'll want to set your `SONIC_RPC_URL` and `PRIVATE_KEY` as environment variables. You can add them to a `.env` file, similar to what you see in `.env.example`.

- `PRIVATE_KEY`: The private key of your account (like from [MetaMask](https://metamask.io/)). **NOTE:** FOR DEVELOPMENT, PLEASE USE A KEY THAT DOESN'T HAVE ANY REAL FUNDS ASSOCIATED WITH IT.
  - You can [learn how to export it here](https://metamask.zendesk.com/hc/en-us/articles/360015289632-How-to-Export-an-Account-Private-Key).
- `SONIC_RPC_URL`: This is the URL of the Sonic S testnet node you're working with.

### 2. Get Testnet S

Head over to [https://soniclabs.com/faucet](https://soniclabs.com/faucet) and get some testnet **S** tokens. You should see the **S** tokens show up in your MetaMask.

### 3. Deploy

```bash
yarn deploy --network sonic_testnet
```