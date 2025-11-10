# Encrypted Prediction Poll System

An end-to-end MVP that captures encrypted prediction poll responses, aggregates results homomorphically on-chain, and decrypts insights only for authorized viewers. The solution is powered by the Zama FHEVM stack and ships with a Hardhat backend plus a RainbowKit-enabled Next.js frontend.

## ✨ Highlights

- **Private submissions** – poll predictions are encrypted in the browser and never appear in plaintext on-chain.
- **Homomorphic analytics** – tallies for each prediction option are computed directly over ciphertext inside the smart contract.
- **Controlled insights** – only administrators and explicitly authorized wallets can decrypt the final totals.
- **RainbowKit UX** – Rainbow wallet connection in the top-right corner, with custom branding and theme.

## 🎥 Demo Video & Deployment

- **📹 Demo Video**: [Download private.mp4](./private.mp4) - Watch the full demonstration of the encrypted prediction poll system
- **🚀 Live Deployment**: [https://privateelf.vercel.app/](https://privateelf.vercel.app/) - Try the live application

## 🔗 Testnet Contracts

- **Sepolia Testnet**:
  - **EncryptedPredictionPoll**: [`0x3761e6BD55139860B513A5F5efd28431a29744bF`](https://sepolia.etherscan.io/address/0x3761e6BD55139860B513A5F5efd28431a29744bF)
  - **FHECounter**: [`0x5EFce65dC1763d9C38fB6474F5f14B29A5E8251A`](https://sepolia.etherscan.io/address/0x5EFce65dC1763d9C38fB6474F5f14B29A5E8251A)

## 📦 Repository Layout

```
encrypted-prediction-poll-system/
├── contracts/               # FHECounter.sol and EncryptedPredictionPoll.sol smart contracts
├── deploy/                  # Hardhat-deploy scripts
├── tasks/                   # Custom Hardhat CLI helpers
├── test/                    # Contract unit tests
├── frontend/                # Next.js + RainbowKit application
├── deployments/             # Saved deployment artifacts
├── private.mp4              # Demo video
└── README.md
```

## 🛠 Prerequisites

- **Node.js 20+**
- **npm 9+** (or a compatible package manager)
- WalletConnect **Project ID** for RainbowKit (`NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID`)
- Access to a Hardhat node or the Zama FHEVM DevNet

## 🚀 Getting Started

### 1. Backend setup

```bash
cd encrypted-prediction-poll-system
npm install
```

Set up the required Hardhat secrets:

```bash
npx hardhat vars set MNEMONIC
npx hardhat vars set INFURA_API_KEY
npx hardhat vars set ETHERSCAN_API_KEY   # optional for verification
```

Compile, test, and deploy locally:

```bash
npm run compile
npm run test
npx hardhat node                                   # run in a separate terminal
npx hardhat deploy --network localhost
```

### 2. Frontend setup

```bash
cd frontend
npm install
```

Create a `.env.local` file in `frontend/`:

```bash
NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=your_project_id_here
```

Generate ABI/addresses for the UI and start the dev server:

```bash
npm run genabi
npm run dev
```

Visit **http://localhost:3000** to use the encrypted prediction poll dashboard.

## 🧠 Smart Contract Overview

`contracts/EncryptedPredictionPoll.sol` & `contracts/FHECounter.sol`:

- Stores the poll metadata, option labels, encrypted tallies, and voting state.
- Accepts encrypted votes (`submitEncryptedVote`) and prevents multiple submissions per address.
- Implements homomorphic tally aggregation for encrypted vote counting.
- Supports oracle-based decryption requests (`requestEncryptedTallyDecryption`) after voting ends.
- Allows creator and authorized users to decrypt tallies locally.
- Manages voting windows with start/end timestamps.

### Hardhat tasks

| Task name             | Description                                              |
| --------------------- | -------------------------------------------------------- |
| `accounts`            | Prints the list of available accounts                    |
| `task:address`        | Prints the FHECounter contract address                   |
| `task:increment`      | Calls the increment function of FHECounter               |
| `task:decrement`      | Calls the decrement function of FHECounter               |
| `poll:address`        | Prints the EncryptedPredictionPoll contract address      |
| `poll:info`           | Displays poll metadata, options, and tallies            |
| `poll:vote`           | Submits an encrypted vote for a given option index       |
| `poll:decrypt`        | Requests oracle decryption once voting has closed        |
| `poll:user-decrypt`   | Decrypts encrypted tallies locally using CLI utilities   |

Run tasks with e.g. `npx hardhat --network localhost poll:address`.

## 🧪 Testing

The `test/` suite runs against the FHEVM mock environment:

```bash
npx hardhat test
```

Tests cover initialization, encrypted submissions, and the authorized viewer flow.

## 🌐 Frontend Workflow

- RainbowKit handles wallet connection with a compact connect button in the top-right corner.
- `useEncryptedPredictionPoll` hook aggregates contract reads, encrypted submission, and FHE decryption.
- The UI surfaces three core states: submission status, authorization status, and decrypted tallies.
- Custom branding (logo, favicon, background) delivered via Tailwind CSS and SVG assets.

## 📄 License

This project is released under the BSD-3-Clause-Clear License. See the [LICENSE](LICENSE) file for details.

## 📚 Further Reading

- [Zama FHEVM Documentation](https://docs.zama.ai/fhevm)
- [FHEVM Hardhat Plugin](https://docs.zama.ai/protocol/solidity-guides/development-guide/hardhat)
- [RainbowKit Documentation](https://www.rainbowkit.com/docs/introduction)

---

Built for encrypted prediction polls – safeguard user predictions from submission to decision.
