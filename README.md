# Heart Lock 💙🔒

A secure FHE-based smart contract project for privacy-preserving counter operations.

## 📹 Demo Video

Watch the project demonstration: [View Demo Video](https://github.com/Sandra264/silent-whisper-draw/blob/master/pro1.mp4)

## 🎯 Overview

Heart Lock implements **Fully Homomorphic Encryption (FHE)** using Zama's fhEVM to enable secure computation on encrypted data without ever decrypting it. This allows for privacy-preserving counter operations where sensitive numerical data remains encrypted throughout all operations.

## ✨ Features

- **Encrypted Counter Operations** - All arithmetic operations on encrypted data
- **Privacy-Preserving Smart Contracts** - No plaintext data exposure
- **Pausable Pattern** - Emergency stop mechanism for security
- **Batch Operations** - Efficient multiple increments in single transaction
- **Access Control** - Owner-only administrative functions
- **Gas Optimized** - Custom errors instead of require statements

## 🏗️ Architecture

### Smart Contract Structure

```solidity
contract FHECounter is SepoliaConfig {
    string public constant VERSION = "1.0.0";
    euint32 private _count;          // Encrypted counter
    address private _owner;          // Contract owner
    bool private _paused;            // Pause state
}
```

### Key Components

1. **FHE Library Integration** - Uses `@fhevm/solidity` for encryption operations
2. **Encrypted State** - Counter stored as `euint32` (encrypted uint32)
3. **Access Control** - Owner-based permissions with custom error handling
4. **Event System** - Comprehensive event logging for all operations

## 🔐 FHE Encryption & Decryption Logic

### Data Encryption Flow

```
User Input (plaintext) 
    ↓
FHE.fromExternal(inputEuint32, inputProof)
    ↓
Encrypted Value (euint32)
    ↓
Operations on Encrypted Data
    ↓
Encrypted Result stored on-chain
```

### Key Encryption Operations

#### 1. **Input Encryption** (User → Contract)
```solidity
function increment(externalEuint32 calldata inputEuint32, bytes calldata inputProof) {
    // Convert external encrypted input to internal encrypted type
    euint32 value = FHE.fromExternal(inputEuint32, inputProof);
    
    // Perform encrypted addition
    _count = FHE.add(_count, value);
    
    // Set permissions for encrypted data access
    FHE.allowThis(_count);      // Allow contract to access
    FHE.allow(_count, msg.sender); // Allow user to access
}
```

**Process:**
- User encrypts value client-side using FHE public key
- Submits encrypted value (`inputEuint32`) with zero-knowledge proof (`inputProof`)
- Contract validates proof and converts to internal encrypted format
- No plaintext value ever touches the blockchain

#### 2. **Encrypted Arithmetic Operations**
```solidity
// Addition on encrypted values
_count = FHE.add(_count, value);

// Subtraction on encrypted values  
_count = FHE.sub(_count, value);

// Initialize encrypted zero
_count = FHE.asEuint32(0);
```

**Key Properties:**
- Operations performed directly on ciphertext
- Result remains encrypted
- Homomorphic property: `Enc(a) ⊕ Enc(b) = Enc(a + b)`
- No intermediate decryption required

#### 3. **Access Control & Permissions**
```solidity
FHE.allowThis(_count);           // Contract can read encrypted value
FHE.allow(_count, msg.sender);   // Specific user can read encrypted value
```

**Permission System:**
- Encrypted data access is strictly controlled
- Only authorized addresses can request decryption
- Uses Access Control List (ACL) on-chain
- Users must prove ownership to decrypt their data

#### 4. **Batch Operations** (Optimization)
```solidity
function batchIncrement(
    externalEuint32 calldata inputEuint32, 
    bytes calldata inputProof, 
    uint8 times
) {
    euint32 value = FHE.fromExternal(inputEuint32, inputProof);
    euint32 result = _count;
    
    // Multiple encrypted additions
    for (uint8 i = 0; i < times; i++) {
        result = FHE.add(result, value);
    }
    _count = result;
}
```

**Efficiency:**
- Reduces transaction count for multiple operations
- All operations remain on encrypted data
- Single permission update at the end

### Decryption Flow (Off-chain)

```
On-chain Encrypted Value
    ↓
User requests decryption with proof of ownership
    ↓
Zama Gateway validates access permissions
    ↓
Gateway decrypts using private key
    ↓
Returns plaintext value to authorized user
```

**Important Notes:**
- Decryption happens **off-chain** via Zama's decryption oracle
- Only authorized addresses can request decryption
- Smart contract never sees plaintext values
- Maintains privacy even from contract itself

### Security Model

```
┌─────────────────────────────────────────┐
│ Client (User)                           │
│ • Encrypts input                        │
│ • Generates proofs                      │
└─────────────┬───────────────────────────┘
              │ encrypted data + proof
              ▼
┌─────────────────────────────────────────┐
│ Smart Contract (On-chain)               │
│ • Validates proofs                      │
│ • Operates on ciphertext                │
│ • Stores encrypted results              │
│ • Never sees plaintext                  │
└─────────────┬───────────────────────────┘
              │ decryption request
              ▼
┌─────────────────────────────────────────┐
│ Zama Gateway (Off-chain)                │
│ • Validates permissions                 │
│ • Performs decryption                   │
│ • Returns plaintext to authorized user  │
└─────────────────────────────────────────┘
```

## 🚀 Getting Started

### Prerequisites

```bash
Node.js >= 16.0.0
npm >= 7.0.0
```

### Installation

```bash
npm install
```

### Compile Contracts

```bash
npm run compile
```

### Deploy

```bash
npm run deploy
```

### Environment Setup

Copy `env.template` to `.env` and configure:
```bash
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_KEY
PRIVATE_KEY=your_private_key
```

## 📋 Contract Functions

### User Functions (Encrypted Operations)
- `increment(value, proof)` - Increment counter with encrypted value
- `decrement(value, proof)` - Decrement counter with encrypted value  
- `batchIncrement(value, proof, times)` - Batch increment operation (max 10x)
- `getCount()` - Get encrypted counter value (requires decryption permission)

### Admin Functions (Owner Only)
- `reset()` - Reset counter to zero
- `pause()` - Pause all counter operations
- `unpause()` - Resume counter operations

### View Functions
- `owner()` - Get contract owner address
- `paused()` - Check if contract is paused
- `VERSION` - Get contract version

## 🛡️ Security Features

1. **Access Control** - Owner-only administrative functions
2. **Pausable Pattern** - Emergency stop mechanism
3. **Custom Errors** - Gas-efficient error handling
4. **Input Validation** - Strict parameter checking
5. **FHE Privacy** - Zero-knowledge proofs for all operations
6. **Permission Management** - Granular access to encrypted data

## 🧪 Testing

```bash
npm run test
```

## 📚 Technical Stack

- **Solidity**: ^0.8.24
- **Hardhat**: Smart contract development framework
- **Zama fhEVM**: Fully homomorphic encryption library
- **TypeScript**: Type-safe development

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Development Workflow
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

MIT License - see [LICENSE](./LICENSE) file for details.

## 🔗 Resources

- [Zama fhEVM Documentation](https://docs.zama.ai/fhevm)
- [Fully Homomorphic Encryption](https://en.wikipedia.org/wiki/Homomorphic_encryption)
- [Hardhat Documentation](https://hardhat.org/docs)

---

**Built with ❤️ by the Heart Lock Team**

