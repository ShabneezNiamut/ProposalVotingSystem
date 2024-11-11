// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./Voting.sol";
import "./ProposalUtils.sol";

contract ProposalContract {
    using Voting for Voting.VoteCounts;
    uint256 private counter;

    struct Proposal {
        string title;
        string description;
        Voting.VoteCounts votes; // Using the VoteCounts struct from Voting library
        uint256 total_vote_to_end;
        bool current_state;
        bool is_active;
    }

    mapping(uint256 => Proposal) public proposal_history;

    event ProposalCreated(uint256 proposalId, string title, string description, uint256 totalVoteToEnd);
    
    // ****************** Execute Functions ***********************

    function createProposal(
        string calldata _title,
        string calldata _description,
        uint256 _total_vote_to_end
    ) external {
        counter += 1;
        proposal_history[counter] = Proposal(
            _title,
            _description,
            Voting.VoteCounts(0, 0, 0),  // Initialize the vote counts
            _total_vote_to_end,
            false,  // Proposal starts as not accepted yet
            true    // Proposal starts as active
        );

        emit ProposalCreated(counter, _title, _description, _total_vote_to_end);
    }

    // Function to vote in favor of the proposal
    function voteApprove(uint256 proposalId) external {
        Proposal storage proposal = proposal_history[proposalId];
        require(proposal.is_active, "Proposal is not active");

        proposal.votes.addApproveVote();  // Increment approve vote using Voting library

        // Check if voting is complete and set the proposal state accordingly
        if (ProposalUtils.isVotingComplete(
            proposal.votes.approve + proposal.votes.reject + proposal.votes.pass,
            proposal.total_vote_to_end
        )) {
            proposal.is_active = false;
            proposal.current_state = calculateCurrentState(proposalId);  // Calculate proposal state
        }
    }

    // Function to calculate the current state of the proposal
    function calculateCurrentState(uint256 proposalId) private view returns(bool) {
        Proposal storage proposal = proposal_history[proposalId];

        uint256 approve = proposal.votes.approve;
        uint256 reject = proposal.votes.reject;
        uint256 pass = proposal.votes.pass;

        // Example logic: Approve votes must be greater than reject + half of pass votes
        if (pass % 2 == 1) {
            pass += 1;  // Round up if pass votes are odd
        }

        pass = pass / 2;  // Half impact for pass votes

        // If approve votes exceed the sum of reject votes and half of pass votes, it's successful
        if (approve > (reject + pass)) {
            return true;
        } else {
            return false;
        }
    }
}
