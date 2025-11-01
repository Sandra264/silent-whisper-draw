// SPDX-License-Identifier: MIT
// Author: Smedley699
// Version: 1.0.0
pragma solidity ^0.8.24;

import {FHE, euint32, externalEuint32} from "@fhevm/solidity/lib/FHE.sol";
import {SepoliaConfig} from "@fhevm/solidity/config/ZamaConfig.sol";

/// @title FHE Counter Contract
/// @author Heart Lock Team
/// @notice Secure counter using fully homomorphic encryption
/// @dev Implements pausable pattern for emergency stops
/// @custom:security-contact security@heartlock.example
contract FHECounter is SepoliaConfig {
    string public constant VERSION = "1.0.0";
    euint32 private _count;
    address private _owner;
    bool private _paused;
    
    event CounterIncremented(address indexed user);
    event CounterDecremented(address indexed user);
    event CounterReset(address indexed user);
    event Paused(address indexed user);
    event Unpaused(address indexed user);
    
    error NotAuthorized();
    error ContractPaused();
    error InvalidParameter();
    
    modifier onlyOwner() {
        if (msg.sender != _owner) revert NotAuthorized();
        _;
    }
    
    modifier whenNotPaused() {
        if (_paused) revert ContractPaused();
        _;
    }
    
    constructor() {
        _owner = msg.sender;
    }
    
    function getCount() external view returns (euint32) {
        return _count;
    }
    
    function owner() external view returns (address) {
        return _owner;
    }
    
    /// @notice Increment counter by encrypted value
    /// @param inputEuint32 The encrypted input value
    /// @param inputProof The proof for the encrypted input
    function increment(externalEuint32 calldata inputEuint32, bytes calldata inputProof) external whenNotPaused {
        euint32 value = FHE.fromExternal(inputEuint32, inputProof);
        _count = FHE.add(_count, value);
        FHE.allowThis(_count);
        FHE.allow(_count, msg.sender);
        emit CounterIncremented(msg.sender);
    }
    
    /// @notice Decrement counter by encrypted value
    function decrement(externalEuint32 calldata inputEuint32, bytes calldata inputProof) external whenNotPaused {
        euint32 value = FHE.fromExternal(inputEuint32, inputProof);
        _count = FHE.sub(_count, value);
        FHE.allowThis(_count);
        FHE.allow(_count, msg.sender);
        emit CounterDecremented(msg.sender);
    }
    
    /// @notice Reset counter to zero (owner only)
    function reset() external onlyOwner {
        _count = FHE.asEuint32(0);
        FHE.allowThis(_count);
        FHE.allow(_count, msg.sender);
        emit CounterReset(msg.sender);
    }
    
    /// @notice Pause the contract
    function pause() external onlyOwner {
        _paused = true;
        emit Paused(msg.sender);
    }
    
    /// @notice Unpause the contract
    function unpause() external onlyOwner {
        _paused = false;
        emit Unpaused(msg.sender);
    }
    
    /// @notice Check if contract is paused
    function paused() external view returns (bool) {
        return _paused;
    }
    
    /// @notice Batch increment operation
    /// @param inputEuint32 The encrypted input value
    /// @param inputProof The proof for the encrypted input
    /// @param times Number of times to increment (max 10)
    function batchIncrement(
        externalEuint32 calldata inputEuint32, 
        bytes calldata inputProof, 
        uint8 times
    ) external whenNotPaused {
        if (times == 0 || times > 10) revert InvalidParameter();
        euint32 value = FHE.fromExternal(inputEuint32, inputProof);
        
        euint32 result = _count;
        for (uint8 i = 0; i < times; i++) {
            result = FHE.add(result, value);
        }
        _count = result;
        
        FHE.allowThis(_count);
        FHE.allow(_count, msg.sender);
        emit CounterIncremented(msg.sender);
    }
}

