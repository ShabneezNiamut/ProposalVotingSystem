// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

library ProposalUtils {
    function isVotingComplete(uint256 totalVotes, uint256 threshold) internal pure returns (bool) {
        return totalVotes >= threshold;
    }
}
