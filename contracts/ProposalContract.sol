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

    function createProposal(
        string calldata _title,
        string calldata _description,
        uint256 _total_vote_to_end
    ) external {
        counter += 1;
        proposal_history[counter] = Proposal(
            _title,
            _description,
            Voting.VoteCounts(0, 0, 0),
            _total_vote_to_end,
            false,
            true
        );

        emit ProposalCreated(counter, _title, _description, _total_vote_to_end);
    }

    function voteApprove(uint256 proposalId) external {
        Proposal storage proposal = proposal_history[proposalId];
        require(proposal.is_active, "Proposal is not active");

        proposal.votes.addApproveVote();

        if (ProposalUtils.isVotingComplete(
            proposal.votes.approve + proposal.votes.reject + proposal.votes.pass,
            proposal.total_vote_to_end
        )) {
            proposal.is_active = false;
            proposal.current_state = proposal.votes.approve > proposal.votes.reject;
        }
    }
}
