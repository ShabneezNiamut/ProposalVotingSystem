// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract ProposalContract {

    address public owner;
    uint256 public proposalIdCounter;

    // Struct for Proposal
    struct Proposal {
        string title; // Title of the proposal (added field)
        string description; // Description of the proposal
        uint256 approve; // Number of approve votes
        uint256 reject; // Number of reject votes
        uint256 pass; // Number of pass votes
        uint256 total_vote_to_end; // When the total votes in the proposal reaches this limit, proposal ends
        bool current_state; // This shows the current state of the proposal, meaning whether it passes or fails
        bool is_active; // This shows if others can vote on the proposal
    }

    // Mapping to store proposal history
    mapping(uint256 => Proposal) public proposal_history;
    // Mapping to check if an address has voted for a proposal
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    // Modifier to ensure only the owner can create proposals
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can create proposals");
        _;
    }

    // Constructor to set the owner
    constructor() {
        owner = msg.sender;
    }

    // Function to create a new proposal with a title and description
    function createProposal(string memory _title, string memory _description, uint256 _totalVoteToEnd) external onlyOwner {
        proposalIdCounter++; // Increment the proposal ID counter

        proposal_history[proposalIdCounter] = Proposal({
            title: _title, // Assign title
            description: _description, // Assign description
            approve: 0,
            reject: 0,
            pass: 0,
            total_vote_to_end: _totalVoteToEnd,
            current_state: false,
            is_active: true
        });
    }

    // Function to vote on a proposal
    function vote(uint256 proposalId, bool approve, bool reject, bool pass) external {
        Proposal storage proposal = proposal_history[proposalId];

        // Ensure the proposal is active
        require(proposal.is_active, "This proposal is no longer active");
        // Ensure the user has not voted before
        require(!hasVoted[proposalId][msg.sender], "You have already voted");

        // Mark the user as having voted
        hasVoted[proposalId][msg.sender] = true;

        // Count the vote based on the user's choice
        if (approve) {
            proposal.approve++;
        }
        if (reject) {
            proposal.reject++;
        }
        if (pass) {
            proposal.pass++;
        }

        // Check if the proposal has reached the total vote limit
        if (proposal.approve + proposal.reject + proposal.pass >= proposal.total_vote_to_end) {
            proposal.is_active = false; // Deactivate the proposal once the vote limit is reached
            proposal.current_state = (proposal.approve > proposal.reject); // Proposal passes if approve votes are higher than reject votes
        }
    }

    // Function to get the state of a proposal
    function getProposalState(uint256 proposalId) external view returns (string memory) {
        Proposal storage proposal = proposal_history[proposalId];

        if (proposal.is_active) {
            return "Voting in progress";
        } else {
            return proposal.current_state ? "Proposal passed" : "Proposal rejected";
        }
    }
}
