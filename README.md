# PollCipher 🗳️🔐

**A privacy-preserving prediction and polling platform powered by Fully Homomorphic Encryption (FHE)**

[![Live Demo](https://img.shields.io/badge/Live-Demo-brightgreen)](https://pro1-orcin.vercel.app/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

🌐 **Live Application**: [https://pro1-orcin.vercel.app/](https://pro1-orcin.vercel.app/)

📹 **Demo Video**: [Watch on GitHub](https://github.com/Sandra264/silent-whisper-draw/blob/main/pro1.mp4)

---

## 🎯 Overview

**PollCipher** enables **completely private voting and prediction markets** using Zama's fhEVM (Fully Homomorphic Encryption Virtual Machine). Votes are encrypted client-side and remain encrypted on-chain throughout the entire voting process. Tallies are computed homomorphically, ensuring that individual votes are never revealed—even to the smart contract itself.

### Why PollCipher?

Traditional on-chain voting systems expose individual votes, making them vulnerable to:
- **Vote buying** - Voters can prove how they voted
- **Voter intimidation** - Public votes can be traced
- **Prediction manipulation** - Early results influence later votes

**PollCipher solves these problems** by keeping all votes encrypted until the poll closes, when results are revealed through a decentralized oracle or local decryption.

---

## ✨ Key Features

### 🔒 **Privacy-First Design**
- ✅ **End-to-end encryption** - Votes encrypted in browser, never exposed
- ✅ **Homomorphic tallying** - Results computed on encrypted data
- ✅ **Zero-knowledge proofs** - Validate votes without revealing content
- ✅ **Private until finalized** - No early results leakage

### 🗳️ **Flexible Polling System**
- ✅ **Multiple options** - Support for binary and multi-choice polls
- ✅ **Time-bounded voting** - Configure start and end times
- ✅ **Oracle finalization** - Automated result decryption
- ✅ **Local decryption** - Users can decrypt results themselves

### 🎨 **Modern User Experience**
- ✅ **Next.js 15 frontend** - Fast, responsive React application
- ✅ **RainbowKit integration** - Easy wallet connection
- ✅ **Real-time updates** - Live poll status and participation
- ✅ **Mobile-friendly** - Works on all devices

### 🛠️ **Developer-Friendly**
- ✅ **Hardhat development environment**
- ✅ **Comprehensive test suite**
- ✅ **TypeScript throughout**
- ✅ **Deployment scripts included**

---

## 🏗️ Architecture

### System Components

```
┌─────────────────────────────────────────────────────────────┐
│                     PollCipher Platform                      │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌─────────────────┐         ┌──────────────────┐          │
│  │  Next.js Frontend│◄────────┤  Zama FHE SDK    │          │
│  │  (React + TS)    │         │  (WASM Runtime)  │          │
│  └────────┬─────────┘         └──────────────────┘          │
│           │                                                   │
│           │ Encrypted Votes + Proofs                         │
│           ▼                                                   │
│  ┌─────────────────────────────────────────────┐            │
│  │     EncryptedPredictionPoll Contract        │            │
│  │  • Accepts encrypted votes                  │            │
│  │  • Homomorphic tally computation            │            │
│  │  • Access control & permissions             │            │
│  │  • Oracle integration                       │            │
│  └────────┬────────────────────────────────────┘            │
│           │                                                   │
│           │ Decryption Request                               │
│           ▼                                                   │
│  ┌─────────────────────────────────────────────┐            │
│  │         Zama Gateway (Off-chain)            │            │
│  │  • Validates access permissions             │            │
│  │  • Performs threshold decryption            │            │
│  │  • Returns final tallies                    │            │
│  └─────────────────────────────────────────────┘            │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

### Smart Contracts

#### **EncryptedPredictionPoll.sol**
The main contract managing the encrypted polling system:
- Stores poll metadata (name, description, options)
- Manages voting lifecycle (start time, end time, finalization)
- Accepts and validates encrypted votes
- Computes homomorphic tallies
- Handles oracle decryption requests
- Emits events for off-chain tracking

#### **FHECounter.sol**
Auxiliary contract for encrypted counter operations:
- Demonstrates basic FHE operations
- Useful for testing and development
- Includes pausable pattern and batch operations

---

## 🔐 How FHE Voting Works

### 1. **Vote Submission (Encrypted)**

```typescript
// Client-side encryption
const encryptedVote = await fhevm.encrypt(optionIndex);
const proof = await fhevm.generateProof(encryptedVote);

// Submit to blockchain
await contract.vote(encryptedVote, proof);
```

The vote is encrypted in the user's browser and never exposed in plaintext.

### 2. **Homomorphic Tallying**

```solidity
// On-chain: Add encrypted vote to encrypted tally
function vote(externalEuint32 calldata encryptedChoice, bytes calldata proof) {
    euint32 choice = FHE.fromExternal(encryptedChoice, proof);
    
    // Homomorphically increment the chosen option's tally
    for (uint8 i = 0; i < numOptions; i++) {
        ebool isChoice = FHE.eq(choice, FHE.asEuint32(i));
        euint32 increment = FHE.select(isChoice, FHE.asEuint32(1), FHE.asEuint32(0));
        _encryptedTallies[i] = FHE.add(_encryptedTallies[i], increment);
    }
}
```

All tally operations happen on encrypted data—no plaintext votes are ever visible.

### 3. **Result Decryption**

**Option A: Oracle Decryption (Public)**
```solidity
function requestDecryption() external {
    require(block.timestamp > endTime, "Poll still active");
    // Request Zama Gateway to decrypt all tallies
    decryptionRequestId = FHE.decrypt(_encryptedTallies);
}
```

**Option B: Local Decryption (Private)**
```typescript
// Only authorized users can decrypt
const tally = await contract.getEncryptedTally(optionIndex);
const decrypted = await fhevm.decrypt(tally);
```

---

## 🚀 Getting Started

### Prerequisites

- **Node.js** >= 18.0.0
- **npm** >= 9.0.0
- **Git**
- **MetaMask** or compatible Web3 wallet

### Installation

```bash
# Clone the repository
git clone https://github.com/Sandra264/silent-whisper-draw.git
cd silent-whisper-draw/pro1

# Install dependencies
npm install

# Install frontend dependencies
cd frontend
npm install
cd ..
```

### Environment Setup

Create `.env` in the project root:

```bash
# Blockchain Configuration
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_INFURA_KEY
PRIVATE_KEY=your_deployer_private_key

# Frontend Configuration (optional)
NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=your_walletconnect_id
```

### Development Workflow

#### 1. **Start Local Blockchain**

```bash
npx hardhat node
```

#### 2. **Deploy Contracts**

```bash
# Deploy to local network
npx hardhat deploy --network localhost

# Deploy to Sepolia testnet
npx hardhat deploy --network sepolia
```

#### 3. **Run Frontend**

```bash
cd frontend

# Generate ABI and addresses
npm run genabi

# Start development server
npm run dev
```

Visit [http://localhost:3000](http://localhost:3000)

---

## 📦 Project Structure

```
pro1/
├── contracts/                    # Smart contracts
│   ├── EncryptedPredictionPoll.sol  # Main voting contract
│   └── FHECounter.sol               # Counter example
├── deploy/                       # Deployment scripts
│   ├── deploy-poll.ts
│   └── deploy.ts
├── test/                         # Contract tests
│   ├── EncryptedPredictionPoll.ts
│   ├── EncryptedPredictionPollSepolia.ts
│   └── FHECounter.ts
├── tasks/                        # Hardhat tasks
│   ├── EncryptedPredictionPoll.ts
│   ├── FHECounter.ts
│   └── accounts.ts
├── frontend/                     # Next.js application
│   ├── app/                      # App router pages
│   ├── components/               # React components
│   ├── hooks/                    # Custom React hooks
│   ├── fhevm/                    # FHE SDK integration
│   ├── abi/                      # Contract ABIs (generated)
│   └── public/                   # Static assets
├── scripts/                      # Utility scripts
├── hardhat.config.ts             # Hardhat configuration
├── package.json                  # Dependencies
├── DEPLOY_SEPOLIA.md            # Deployment guide
└── README.md                    # This file
```

---

## 🧪 Testing

### Run Contract Tests

```bash
# Run all tests
npm test

# Run specific test file
npx hardhat test test/EncryptedPredictionPoll.ts

# Run with gas reporting
REPORT_GAS=true npm test

# Run coverage
npm run coverage
```

### Test Frontend

```bash
cd frontend
npm run test
```

---

## 🌐 Deployment

### Deploy to Sepolia Testnet

1. **Fund your deployer wallet** with Sepolia ETH (use a faucet)
2. **Configure `.env`** with your Sepolia RPC and private key
3. **Deploy contracts:**

```bash
npx hardhat deploy --network sepolia
```

4. **Generate frontend ABIs:**

```bash
cd frontend
npm run genabi
```

5. **Deploy frontend to Vercel:**

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
cd frontend
vercel --prod
```

For detailed deployment instructions, see [DEPLOY_SEPOLIA.md](./DEPLOY_SEPOLIA.md).

---

## 📋 Usage Guide

### For Poll Creators

1. **Deploy a poll contract** with your desired options
2. **Set voting window** (start and end times)
3. **Share the poll link** with participants
4. **Wait for voting to complete**
5. **Request decryption** to reveal results
6. **Publish results** to the community

### For Voters

1. **Connect your wallet** (MetaMask, Rainbow, etc.)
2. **View available polls** on the homepage
3. **Select your prediction** from the options
4. **Submit encrypted vote** (one vote per address)
5. **Wait for poll to close**
6. **View results** once decrypted

---

## 🛡️ Security Features

### Cryptographic Security
- ✅ **FHE encryption** - Industry-standard lattice-based cryptography
- ✅ **Zero-knowledge proofs** - Validate without revealing
- ✅ **Threshold decryption** - No single point of failure

### Smart Contract Security
- ✅ **Access control** - Owner-only administrative functions
- ✅ **Time locks** - Prevent early finalization
- ✅ **Reentrancy protection** - Secure external calls
- ✅ **Input validation** - Comprehensive parameter checking
- ✅ **Event logging** - Complete audit trail

### Operational Security
- ✅ **One vote per address** - Prevent double voting
- ✅ **Vote anonymity** - Cannot link votes to voters
- ✅ **Result integrity** - Cryptographically guaranteed tallies
- ✅ **Finalization locks** - Results cannot be altered

---

## 📚 Technical Stack

### Smart Contracts
- **Solidity** ^0.8.24
- **Hardhat** - Development environment
- **Zama fhEVM** - Homomorphic encryption library
- **OpenZeppelin** - Security patterns

### Frontend
- **Next.js** 15 - React framework
- **TypeScript** - Type safety
- **RainbowKit** - Wallet connection
- **Wagmi** - React hooks for Ethereum
- **TailwindCSS** - Styling
- **Zama FHE SDK** - Client-side encryption

### Infrastructure
- **Vercel** - Frontend hosting
- **Sepolia** - Ethereum testnet
- **Infura/Alchemy** - RPC providers
- **IPFS** - Decentralized storage (optional)

---

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Make your changes** and test thoroughly
4. **Commit with conventional commits**: `git commit -m 'feat: add amazing feature'`
5. **Push to your fork**: `git push origin feature/amazing-feature`
6. **Open a Pull Request**

### Development Guidelines
- Follow the existing code style
- Add tests for new features
- Update documentation as needed
- Ensure all tests pass before submitting

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](./LICENSE) file for details.

The frontend components use **BSD-3-Clause-Clear** license from Zama's template.

---

## 🔗 Resources

### Documentation
- [Zama fhEVM Documentation](https://docs.zama.ai/fhevm)
- [Fully Homomorphic Encryption Explained](https://en.wikipedia.org/wiki/Homomorphic_encryption)
- [Hardhat Documentation](https://hardhat.org/docs)
- [Next.js Documentation](https://nextjs.org/docs)

### Related Projects
- [Zama fhEVM](https://github.com/zama-ai/fhevm)
- [RainbowKit](https://www.rainbowkit.com/)
- [Wagmi](https://wagmi.sh/)

### Community
- [Zama Discord](https://discord.gg/zama)
- [Report Issues](https://github.com/Sandra264/silent-whisper-draw/issues)

---

## 🎯 Use Cases

### Prediction Markets
Create encrypted prediction markets where participants vote on future events without revealing their predictions until the market closes.

### Private Governance
Enable DAOs and organizations to conduct votes where individual choices remain private, preventing vote buying and coercion.

### Opinion Polls
Gather honest feedback through truly anonymous surveys where responses cannot be traced back to individuals.

### Blind Auctions
Run sealed-bid auctions where bids remain encrypted until the bidding period ends.

---

## 🚧 Roadmap

- [x] Core FHE voting contract
- [x] Next.js frontend with wallet integration
- [x] Local and oracle decryption
- [x] Sepolia testnet deployment
- [x] Production deployment on Vercel
- [ ] Multi-poll support in single contract
- [ ] NFT-gated polls
- [ ] Token-weighted voting
- [ ] Mobile app (React Native)
- [ ] Mainnet deployment

---

## 👥 Team

**Built with ❤️ by the PollCipher Team**

- **Sandra264** - Frontend & UI/UX
- **Smedley699** - Smart Contracts & Backend

---

## 📞 Contact

For questions, suggestions, or collaborations:

- **GitHub Issues**: [Report a bug or request a feature](https://github.com/Sandra264/silent-whisper-draw/issues)
- **Project Link**: [https://github.com/Sandra264/silent-whisper-draw](https://github.com/Sandra264/silent-whisper-draw)
- **Live Demo**: [https://pro1-orcin.vercel.app/](https://pro1-orcin.vercel.app/)

---

**⭐ Star this repo if you find it useful!**

