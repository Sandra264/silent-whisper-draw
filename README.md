# PollCipher 🗳️�?

**A privacy-preserving prediction and polling platform powered by Fully Homomorphic Encryption (FHE)**

[![Live Demo](https://img.shields.io/badge/Live-Demo-brightgreen)](https://pro1-orcin.vercel.app/)

🌐 **Live Application**: [https://pro1-orcin.vercel.app/](https://pro1-orcin.vercel.app/)
📹 **Demo Video**: [Watch on GitHub](https://github.com/Sandra264/silent-whisper-draw/blob/main/pro1.mp4)

## Overview

PollCipher enables completely private voting using Zama's fhEVM.


## Installation

```bash
npm install
```


## How It Works

Votes are encrypted client-side using FHE SDK.


## Contract Functions

- increment() - Add encrypted value
- decrement() - Subtract encrypted value


## Architecture

PollCipher uses a three-tier architecture:
- Frontend (Next.js)
- Smart Contracts (Solidity)
- FHE SDK (Zama)

