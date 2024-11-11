// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

library Voting {
    struct VoteCounts {
        uint256 approve;
        uint256 reject;
        uint256 pass;
    }

    function addApproveVote(VoteCounts storage counts) internal {
        counts.approve += 1;
    }

    function addRejectVote(VoteCounts storage counts) internal {
        counts.reject += 1;
    }

    function addPassVote(VoteCounts storage counts) internal {
        counts.pass += 1;
    }
}
