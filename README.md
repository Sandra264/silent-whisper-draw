# PollCipher 🗳️�?

A privacy-preserving prediction and polling platform powered by FHE.

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

