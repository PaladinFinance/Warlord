//██████╗  █████╗ ██╗      █████╗ ██████╗ ██╗███╗   ██╗
//██╔══██╗██╔══██╗██║     ██╔══██╗██╔══██╗██║████╗  ██║
//██████╔╝███████║██║     ███████║██║  ██║██║██╔██╗ ██║
//██╔═══╝ ██╔══██║██║     ██╔══██║██║  ██║██║██║╚██╗██║
//██║     ██║  ██║███████╗██║  ██║██████╔╝██║██║ ╚████║
//╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚═╝╚═╝  ╚═══╝

pragma solidity 0.8.16;
//SPDX-License-Identifier: BUSL-1.1

import "./BaseLocker.sol";
import "interfaces/IIncentivizedLocker.sol";
import {
  IQuestDistributor,
  IDelegationDistributor,
  IVotiumDistributor,
  IHiddenHandsDistributor
} from "interfaces/external/incentives/IIncentivesDistributors.sol";
import {Errors} from "utils/Errors.sol";

/**
 * @title Incentivized Locker contract
 * @author Paladin
 * @notice Locker contract cpapble of claiming vote rewards from different sources
 */
abstract contract IncentivizedLocker is WarBaseLocker, IIncentivizedLocker {
  using SafeERC20 for IERC20;

  /**
   * @notice Checks that the caller is the controller
   */
  modifier onlyController() {
    if (msg.sender != controller) revert Errors.CallerNotAllowed();
    _;
  }

  /**
   * @notice Claims voting rewards from Quest
   * @param distributor Address of the contract distributing the rewards
   * @param questID ID of the Quest to claim rewards from
   * @param period Timestamp of the Quest period to claim
   * @param index Index in the Merkle Tree
   * @param account Address claiming the rewards
   * @param amount Amount to claim
   * @param merkleProof Merkle Proofs for the claim
   */
  function claimQuestRewards(
    address distributor,
    uint256 questID,
    uint256 period,
    uint256 index,
    address account,
    uint256 amount,
    bytes32[] calldata merkleProof
  ) external nonReentrant onlyController {
    IQuestDistributor _distributor = IQuestDistributor(distributor);
    IERC20 _token = IERC20(_distributor.questRewardToken(questID));

    _distributor.claim(questID, period, index, account, amount, merkleProof);

    _token.safeTransfer(controller, amount);
  }

  /**
   * @notice Claims voting rewards from the Paladin Delegation address
   * @param distributor Address of the contract distributing the rewards
   * @param token Address of the reward token to claim
   * @param index Index in the Merkle Tree
   * @param account Address claiming the rewards
   * @param amount Amount to claim
   * @param merkleProof Merkle Proofs for the claim
   */
  function claimDelegationRewards(
    address distributor,
    address token,
    uint256 index,
    address account,
    uint256 amount,
    bytes32[] calldata merkleProof
  ) external nonReentrant onlyController {
    IDelegationDistributor(distributor).claim(token, index, account, amount, merkleProof);

    IERC20(token).safeTransfer(controller, amount);
  }

  /**
   * @notice Claims voting rewards from Votium
   * @param distributor Address of the contract distributing the rewards
   * @param token Address of the reward token to claim
   * @param index Index in the Merkle Tree
   * @param account Address claiming the rewards
   * @param amount Amount to claim
   * @param merkleProof Merkle Proofs for the claim
   */
  function claimVotiumRewards(
    address distributor,
    address token,
    uint256 index,
    address account,
    uint256 amount,
    bytes32[] calldata merkleProof
  ) external nonReentrant onlyController {
    IVotiumDistributor(distributor).claim(token, index, account, amount, merkleProof);

    IERC20(token).safeTransfer(controller, amount);
  }

  /**
   * @notice Claims voting rewards from HiddenHands
   * @param distributor Address of the contract distributing the rewards
   * @param claimParams Parameters for claims
   */
  function claimHiddenHandsRewards(address distributor, IHiddenHandsDistributor.Claim[] calldata claimParams)
    external
    nonReentrant
    onlyController
  {
    require(claimParams.length == 1);

    IHiddenHandsDistributor _distributor = IHiddenHandsDistributor(distributor);
    address token = _distributor.rewards(claimParams[0].identifier).token;

    _distributor.claim(claimParams);

    IERC20(token).safeTransfer(controller, claimParams[0].amount);
  }
}
