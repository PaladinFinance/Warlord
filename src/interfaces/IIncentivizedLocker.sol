// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import {IHiddenHandsDistributor} from "interfaces/external/incentives/IIncentivesDistributors.sol";

interface IIncentivizedLocker {
  function claimQuestRewards(
    address distributor,
    uint256 questID,
    uint256 period,
    uint256 index,
    address account,
    uint256 amount,
    bytes32[] calldata merkleProof
  ) external;

  function claimDelegationRewards(
    address distributor,
    address token,
    uint256 index,
    address account,
    uint256 amount,
    bytes32[] calldata merkleProof
  ) external;

  function claimVotiumRewards(
    address distributor,
    address token,
    uint256 index,
    address account,
    uint256 amount,
    bytes32[] calldata merkleProof
  ) external;

  function claimHiddenHandsRewards(address distributor, IHiddenHandsDistributor.Claim[] calldata claimParams) external;
}
