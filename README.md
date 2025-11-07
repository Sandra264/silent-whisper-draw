# PollCipher 🗳️🔐

**A privacy-preserving prediction and polling platform powered by Fully Homomorphic Encryption (FHE)**

[![Live Demo](https://img.shields.io/badge/Live-Demo-brightgreen)](https://pro1-orcin.vercel.app/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

🌐 **Live Application**: [https://pro1-orcin.vercel.app/](https://pro1-orcin.vercel.app/)
📹 **Demo Video**: [Watch on GitHub](https://github.com/Sandra264/silent-whisper-draw/blob/main/pro1.mp4)

## 🎯 Overview

**PollCipher** enables **completely private voting and prediction markets** using Zama's fhEVM. Votes are encrypted client-side and remain encrypted on-chain throughout the entire voting process.

## ✨ Key Features

- 🔒 **End-to-end encryption** - Votes encrypted in browser
- 🗳️ **Homomorphic tallying** - Results computed on encrypted data  
- ✅ **Zero-knowledge proofs** - Validate without revealing
- 🎨 **Modern UI** - Next.js 15 with RainbowKit

## 🏗️ Architecture

PollCipher uses Fully Homomorphic Encryption to enable:
- Private voting without revealing individual choices
- Homomorphic tally computation
- Oracle-based or local result decryption

### Smart Contracts

- **FHECounter.sol** - Encrypted counter with pausable pattern
- **EncryptedPredictionPoll.sol** - Main voting contract

## 🔐 How FHE Works

### Vote Encryption
```typescript
const encryptedVote = await fhevm.encrypt(optionIndex);
await contract.vote(encryptedVote, proof);
```

### Homomorphic Tallying
```solidity
// On-chain: operations on encrypted data
_count = FHE.add(_count, encryptedValue);
```

### Access Control
```solidity
FHE.allowThis(_count);      // Contract access
FHE.allow(_count, msg.sender); // User access
```

## 🚀 Getting Started

### Installation
```bash
git clone https://github.com/Sandra264/silent-whisper-draw.git
cd silent-whisper-draw/pro1
npm install
```

### Deploy Contracts
```bash
npx hardhat deploy --network sepolia
```

### Run Frontend
```bash
cd frontend
npm run genabi
npm run dev
```

## 📋 Contract Functions

### User Functions
- increment(value, proof) - Add encrypted value
- decrement(value, proof) - Subtract encrypted value
- batchIncrement(value, proof, times) - Batch operation
- getCount() - Get encrypted counter

### Admin Functions  
- reset() - Reset counter (owner only)
- pause() - Pause operations
- unpause() - Resume operations

## 🛡️ Security Features

- **FHE Encryption** - Lattice-based cryptography
- **Access Control** - Owner-only admin functions
- **Pausable Pattern** - Emergency stop mechanism
- **Custom Errors** - Gas-optimized error handling
- **Input Validation** - Comprehensive parameter checks
- **Event Logging** - Complete audit trail

## 📚 Technical Stack

- **Solidity** ^0.8.24
- **Hardhat** - Development environment
- **Zama fhEVM** - Homomorphic encryption
- **Next.js** 15 - Frontend framework
- **TypeScript** - Type safety
- **RainbowKit** - Wallet connection

## 🤝 Contributing

Contributions welcome! Please follow conventional commits.

## 📄 License

MIT License - see LICENSE file for details.

## 🔗 Resources

- [Zama fhEVM Documentation](https://docs.zama.ai/fhevm)
- [Hardhat Documentation](https://hardhat.org/docs)
- [Next.js Documentation](https://nextjs.org/docs)

## 👥 Team

- **Sandra264** - Frontend & UI/UX
- **Smedley699** - Smart Contracts & Backend

---

**⭐ Star this repo if you find it useful!**

## 📖 Usage Examples

### Deploy Contract
```bash
npx hardhat deploy --network sepolia
```  

### Interact with Contract
```bash
npx hardhat fhe:increment --value 5
```
