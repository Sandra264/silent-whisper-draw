// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {FHE, euint32, externalEuint32, ebool} from "@fhevm/solidity/lib/FHE.sol";
import {SepoliaConfig} from "@fhevm/solidity/config/ZamaConfig.sol";

/// @title EncryptedPredictionPoll
/// @author PollCipher
/// @notice Fully homomorphic encrypted polling contract that aggregates private votes.
/// @notice Tallies remain encrypted until participants decrypt locally or an oracle finalises the poll.
/// @dev The contract manages a single poll with a fixed set of options. Votes are submitted as encrypted indices
///      and tallied homomorphically. After the voting window ends anyone can request oracle decryption and the
///      clear tallies become publicly available once the callback succeeds.
/// @dev Security Considerations:
///      - Uses FHE for vote privacy and tally aggregation
///      - Creator has privileged access to encrypted tallies
///      - Oracle decryption provides final immutable results
///      - Re-entrancy protection through state checks
contract EncryptedPredictionPoll is SepoliaConfig {
    /// @notice Metadata describing each option that can be voted for.
    struct Option {
        string label;
        string description;
    }

    /// @notice High level description of the poll scenario.
    string public pollName;
    /// @notice Marketing headline surfaced in the hero section.
    string public pollHeadline;
    /// @notice Detailed poll description displayed in the UI.
    string public pollDescription;

    /// @notice Unix timestamps representing the active voting window.
    uint256 public startTime;
    /// @notice Timestamp (seconds) when the voting window closes.
    uint256 public endTime;

    /// @notice Address that deployed the poll and receives privileged decrypt permissions.
    address public creator;

    /// @notice Total number of voters that successfully submitted an encrypted ballot.
    uint256 public voterCount;

    /// @notice Flags representing the current lifecycle state.
    bool public finalized;
    /// @notice Flag indicating whether an oracle decryption request is outstanding.
    bool public decryptionPending;

    /// @notice Oracle request id for the outstanding decryption operation (if any).
    uint256 public decryptionRequestId;

    /// @dev Per-option encrypted vote tallies.
    euint32[] private _encryptedTallies;

    /// @dev Per-option clear vote tallies filled once a decryption request succeeds.
    uint32[] private _clearTallies;

    /// @dev Human readable option metadata.
    Option[] private _options;

    /// @notice Tracks whether an address has already cast a ballot.
    mapping(address voter => bool voted) public hasVoted;

    /// @notice Emitted when a new encrypted ballot is processed.
    /// @param voter Address of the wallet that submitted the encrypted vote.
    event VoteSubmitted(address indexed voter);

    /// @notice Emitted when a decryption request is sent to the oracle network.
    /// @param requestId Identifier returned by `FHE.requestDecryption`.
    event TallyDecryptionRequested(uint256 indexed requestId);

    /// @notice Emitted when poll creator changes.
    /// @param oldCreator Previous creator address.
    /// @param newCreator New creator address.
    event CreatorTransferred(address indexed oldCreator, address indexed newCreator);

    /// @notice Emitted once the oracle returns the decrypted tallies.
    /// @param clearTallies Finalised counts for each poll option.
    event TallyFinalized(uint32[] clearTallies);

    /// @dev Enforce valid option index ranges.
    error InvalidOptionIndex(uint256 index);

    /// @dev Thrown when attempting to vote outside of the allowed window.
    error VotingClosed();

    /// @dev Thrown when the caller already voted.
    error AlreadyVoted();

    /// @dev Thrown when decrypt is requested while a previous request is still pending.
    error DecryptionAlreadyPending();

    /// @dev Thrown when attempting to access clear tallies before finalization.
    error TallyNotFinalized();

    /// @dev Thrown when attempting to finalize more than once.
    error AlreadyFinalized();

    /// @dev Thrown when an unexpected decryption callback is received.
    error UnexpectedCallback();

    /// @dev Thrown when a tally request is attempted before the voting window closes.
    error VotingStillOpen();

    /// @dev Thrown when the provided options array is shorter than the required minimum.
    error InsufficientOptions();

    /// @dev Thrown when option labels and descriptions arrays have mismatched lengths.
    error MismatchedOptionMetadata();

    /// @dev Thrown when the requested voting duration is zero.
    error InvalidVotingDuration();

    /// @dev Thrown when oracle decrypted tallies length does not match configured options length.
    error InvalidTallyLength();

    /// @notice Deploy a new encrypted prediction poll.
    /// @param name Short internal name of the poll.
    /// @param headline Marketing friendly headline shown in the UI hero section.
    /// @param description Optional detailed description of the poll context.
    /// @param optionLabels Labels for each vote option (minimum 2).
    /// @param optionDescriptions Optional per-option descriptions (must match labels array length).
    /// @param votingDurationSeconds Duration of the voting window starting from deployment time.
    constructor(
        string memory name,
        string memory headline,
        string memory description,
        string[] memory optionLabels,
        string[] memory optionDescriptions,
        uint256 votingDurationSeconds
    ) {
        if (optionLabels.length < 2) {
            revert InsufficientOptions();
        }
        if (optionDescriptions.length != optionLabels.length) {
            revert MismatchedOptionMetadata();
        }
        if (votingDurationSeconds == 0) {
            revert InvalidVotingDuration();
        }

        pollName = name;
        pollHeadline = headline;
        pollDescription = description;
        creator = msg.sender;

        startTime = block.timestamp;
        endTime = block.timestamp + votingDurationSeconds;

        for (uint256 i = 0; i < optionLabels.length; ++i) {
            _options.push(Option({label: optionLabels[i], description: optionDescriptions[i]}));
            _encryptedTallies.push(FHE.asEuint32(uint32(0)));
            _clearTallies.push(0);
            FHE.allow(_encryptedTallies[i], creator);
        }
    }

    /// @notice Return the number of available voting options.
    /// @return count Number of configured poll options.
    function optionCount() external view returns (uint256) {
        return _options.length;
    }

    /// @notice Accessor for option metadata.
    /// @param index Zero-based option index.
    /// @return option Option metadata containing label and description.
    function getOption(uint256 index) external view returns (Option memory) {
        if (_options.length == 0 || index > _options.length - 1) {
            revert InvalidOptionIndex(index);
        }
        return _options[index];
    }

    /// @notice Get all poll options metadata in a single call.
    /// @return options Array of all option metadata containing labels and descriptions.
    function getAllOptions() external view returns (Option[] memory) {
        return _options;
    }

    /// @notice Fetch the encrypted tally handle for a specific option.
    /// @param index Zero-based option index.
    /// @return tallyHandle Ciphertext handle representing the encrypted count.
    function getEncryptedTally(uint256 index) external view returns (euint32) {
        if (_encryptedTallies.length == 0 || index > _encryptedTallies.length - 1) {
            revert InvalidOptionIndex(index);
        }
        return _encryptedTallies[index];
    }

    /// @notice Return the clear tally for a specific option once the oracle finalizes the decryption.
    /// @param index Zero-based option index.
    /// @return count Cleartext tally count.
    function getClearTally(uint256 index) external view returns (uint32) {
        if (!finalized) {
            revert TallyNotFinalized();
        }
        if (_clearTallies.length == 0 || index > _clearTallies.length - 1) {
            revert InvalidOptionIndex(index);
        }
        return _clearTallies[index];
    }

    /// @notice Cast an encrypted vote for one of the options.
    /// @param encryptedOption The encrypted option index produced client-side.
    /// @param inputProof zk proof validating the encrypted input (generated alongside the handle).
    function submitEncryptedVote(externalEuint32 encryptedOption, bytes calldata inputProof) external {
        if (block.timestamp < startTime || block.timestamp > endTime) {
            revert VotingClosed();
        }
        if (hasVoted[msg.sender]) {
            revert AlreadyVoted();
        }

        euint32 choice = FHE.fromExternal(encryptedOption, inputProof);

        for (uint256 i = 0; i < _encryptedTallies.length; ++i) {
            ebool isMatch = FHE.eq(choice, FHE.asEuint32(uint32(i)));
            euint32 increment = FHE.select(isMatch, FHE.asEuint32(uint32(1)), FHE.asEuint32(uint32(0)));
            _encryptedTallies[i] = FHE.add(_encryptedTallies[i], increment);
            FHE.allowThis(_encryptedTallies[i]);
            FHE.allow(_encryptedTallies[i], msg.sender);
            FHE.allow(_encryptedTallies[i], creator);
        }

        hasVoted[msg.sender] = true;
        ++voterCount;
        emit VoteSubmitted(msg.sender);
    }

    /// @notice Trigger a decryption request once the voting window closes.
    /// @return requestId Identifier of the oracle decryption request.
    function requestEncryptedTallyDecryption() external returns (uint256) {
        if (block.timestamp == endTime || block.timestamp < endTime) {
            revert VotingStillOpen();
        }
        if (finalized) {
            revert AlreadyFinalized();
        }
        if (decryptionPending) {
            revert DecryptionAlreadyPending();
        }

        bytes32[] memory ciphertexts = new bytes32[](_encryptedTallies.length);
        for (uint256 i = 0; i < _encryptedTallies.length; ++i) {
            ciphertexts[i] = FHE.toBytes32(_encryptedTallies[i]);
        }

        uint256 requestId = FHE.requestDecryption(ciphertexts, this.decryptionCallback.selector);
        decryptionPending = true;
        decryptionRequestId = requestId;

        emit TallyDecryptionRequested(requestId);
        return requestId;
    }

    /// @notice Oracle callback invoked with the decrypted tallies.
    /// @param requestId Oracle request identifier.
    /// @param cleartexts ABI-encoded array containing the clear tallies.
    /// @param signatures Signature bundle returned by the oracle.
    /// @return success Boolean flag for relayers; always true when no revert occurs.
    function decryptionCallback(
        uint256 requestId,
        bytes memory cleartexts,
        bytes memory signatures
    ) public returns (bool) {
        if (!decryptionPending || requestId != decryptionRequestId) {
            revert UnexpectedCallback();
        }

        FHE.checkSignatures(requestId, cleartexts, signatures);

        uint32[] memory tallies = abi.decode(cleartexts, (uint32[]));
        if (tallies.length != _clearTallies.length) {
            revert InvalidTallyLength();
        }

        for (uint256 i = 0; i < tallies.length; ++i) {
            _clearTallies[i] = tallies[i];
        }

        finalized = true;
        decryptionPending = false;

        emit TallyFinalized(tallies);
        return true;
    }

    /// @notice Helper returning whether the voting window is currently open.
    /// @return isOpen True when the poll accepts encrypted ballots.
    function isVotingOpen() external view returns (bool isOpen) {
        bool afterStart = block.timestamp > startTime || block.timestamp == startTime;
        bool beforeEnd = block.timestamp < endTime;
        bool onEnd = block.timestamp == endTime;
        isOpen = afterStart && (beforeEnd || onEnd) && !finalized;
    }

    /// @notice Check if an address is eligible to vote.
    /// @param voter Address to check voting eligibility for.
    /// @return canVote True if the address can submit a vote.
    function canVote(address voter) external view returns (bool) {
        if (hasVoted[voter]) return false;
        if (block.timestamp < startTime || block.timestamp > endTime) return false;
        if (finalized) return false;
        return true;
    }

    /// @notice Get voting statistics summary.
    /// @return totalVotes Total number of votes cast.
    /// @return uniqueVoters Number of unique addresses that voted.
    /// @return timeRemaining Seconds until voting ends (0 if ended).
    /// @return isActive Whether voting is currently active.
    function getVotingStatistics() external view returns (
        uint256 totalVotes,
        uint256 uniqueVoters,
        uint256 timeRemaining,
        bool isActive
    ) {
        totalVotes = voterCount;
        uniqueVoters = voterCount; // Each vote is from a unique voter
        isActive = isVotingOpen();
        if (block.timestamp >= endTime) {
            timeRemaining = 0;
        } else {
            timeRemaining = endTime - block.timestamp;
        }
    }

    /// @notice Transfer poll ownership to a new creator.
    /// @param newCreator Address of the new poll creator.
    function transferCreator(address newCreator) external {
        if (msg.sender != creator) {
            revert("Only creator can transfer ownership");
        }
        if (newCreator == address(0)) {
            revert("New creator cannot be zero address");
        }
        if (newCreator == creator) {
            revert("New creator cannot be the same as current creator");
        }
        address oldCreator = creator;
        creator = newCreator;
        emit CreatorTransferred(oldCreator, newCreator);
    }

    /// @notice Get a summary of the poll state for quick status checks.
    /// @return name Poll name.
    /// @return headline Poll headline.
    /// @return voterCount Total number of votes cast.
    /// @return isActive Whether voting is currently active.
    /// @return isFinalized Whether results are finalized.
    function getPollSummary() external view returns (
        string memory name,
        string memory headline,
        uint256 voterCount,
        bool isActive,
        bool isFinalized
    ) {
        return (
            pollName,
            pollHeadline,
            voterCount,
            isVotingOpen(),
            finalized
        );
    }

    /// @notice Get time information for countdown displays.
    /// @return timeToStart Seconds until voting starts (0 if already started).
    /// @return timeToEnd Seconds until voting ends (0 if already ended).
    /// @return currentTime Current block timestamp.
    function getTimeInfo() external view returns (uint256 timeToStart, uint256 timeToEnd, uint256 currentTime) {
        currentTime = block.timestamp;
        if (currentTime < startTime) {
            timeToStart = startTime - currentTime;
            timeToEnd = endTime - startTime;
        } else if (currentTime < endTime) {
            timeToStart = 0;
            timeToEnd = endTime - currentTime;
        } else {
            timeToStart = 0;
            timeToEnd = 0;
        }
    }

    /// @notice Get the current voting progress statistics.
    /// @return totalVoters Number of voters who have cast ballots.
    /// @return hasStarted Whether voting period has begun.
    /// @return hasEnded Whether voting period has ended.
    /// @return timeRemaining Seconds remaining until voting ends (0 if ended).
    function getVotingProgress() external view returns (uint256 totalVoters, bool hasStarted, bool hasEnded, uint256 timeRemaining) {
        totalVoters = voterCount;
        hasStarted = block.timestamp >= startTime;
        hasEnded = block.timestamp > endTime;
        if (hasEnded) {
            timeRemaining = 0;
        } else {
            timeRemaining = endTime - block.timestamp;
        }
    }
}
