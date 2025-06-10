//██████╗  █████╗ ██╗      █████╗ ██████╗ ██╗███╗   ██╗
//██╔══██╗██╔══██╗██║     ██╔══██╗██╔══██╗██║████╗  ██║
//██████╔╝███████║██║     ███████║██║  ██║██║██╔██╗ ██║
//██╔═══╝ ██╔══██║██║     ██╔══██║██║  ██║██║██║╚██╗██║
//██║     ██║  ██║███████╗██║  ██║██████╔╝██║██║ ╚████║
//╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚═╝╚═╝  ╚═══╝

pragma solidity 0.8.16;
//SPDX-License-Identifier: None

import {Owner} from "utils/Owner.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {Pausable} from "openzeppelin/security/Pausable.sol";
import {ReentrancyGuard} from "openzeppelin/security/ReentrancyGuard.sol";
import {Errors} from "utils/Errors.sol";
import {IHarvestable} from "interfaces/IHarvestable.sol";
import {IMinter} from "interfaces/IMinter.sol";
import {IStaker} from "interfaces/IStaker.sol";
import {IFarmer} from "interfaces/IFarmer.sol";
import {IIncentivizedLocker} from "interfaces/IIncentivizedLocker.sol";
import "interfaces/external/incentives/IIncentivesDistributors.sol";

/**
 * @title Warlord Controller contract - Shutdown version
 * @author Paladin
 * @notice Controller to handle the shutdown process of the Warlord protocol
 */
contract WarShutdownController is ReentrancyGuard, Pausable, Owner {
  using SafeERC20 for IERC20;

  // Constants

  /**
   * @notice 1e18 scale
   */
  uint256 public constant UNIT = 1e18;
  /**
   * @notice Max BPS value (100%)
   */
  uint256 public constant MAX_BPS = 10_000;

  // Storage

  /**
   * @notice Address of the WAR token
   */
  address public immutable war;
  /**
   * @notice Address of the Minter contract
   */
  IMinter public minter;
  /**
   * @notice Address of the Staker contract
   */
  IStaker public staker;
  /**
   * @notice Address of the Manager
   */
  address public manager;
  /**
   * @notice Ratio of fees taken on harvested rewards
   */
  uint256 public feeRatio = 500;
  /**
   * @notice Address to receive the fees
   */
  address public feeReceiver;

  /**
   * @notice Amounts of tokens available for swaps to WETH
   */
  mapping(address => uint256) public swapperAmounts;

  // Events

  /**
   * @notice Event emitted when tokens are pulled
   */
  event PullTokens(address indexed swapper, address indexed token, uint256 amount);
  /**
   * @notice Event emitted when the Fee Ratio is updated
   */
  event SetFeeRatio(uint256 oldFeeRatio, uint256 newFeeRatio);

  // Modifiers

  /**
   * @notice Checks the caller is the Swapper address
   */
  modifier onlyManager() {
    if (msg.sender != manager) revert Errors.CallerNotAllowed();
    _;
  }

  // Constructor

  constructor(
    address _war,
    address _minter,
    address _staker,
    address _manager,
    address _feeReceiver
  ) {
    if (
      _war == address(0) || _minter == address(0) || _staker == address(0) || _manager == address(0)
        || _feeReceiver == address(0)
    ) revert Errors.ZeroAddress();

    war = _war;
    minter = IMinter(_minter);
    staker = IStaker(_staker);
    manager = _manager;
    feeReceiver = _feeReceiver;
  }

  // State changing functions
  function _harvest(address target) internal {
    IHarvestable(target).harvest();
  }

  /**
   * @notice Harvests rewards from a given Harvestable contract
   * @param target Address of the contract to harvest from
   */
  function harvest(address target) external nonReentrant whenNotPaused onlyManager {
    _harvest(target);
  }

  /**
   * @notice Harvests rewards from Harvestable contracts
   * @param targets List of contracts to harvest from
   */
  function harvestMultiple(address[] calldata targets) external nonReentrant whenNotPaused onlyManager {
    uint256 length = targets.length;
    if (length == 0) revert Errors.EmptyArray();

    for (uint256 i; i < length;) {
      _harvest(targets[i]);

      unchecked {
        i++;
      }
    }
  }

  /**
   * @notice Processes tokens held in this contract
   * @param tokens List of tokens to process
   */
  function processMultiple(address[] calldata tokens) external nonReentrant whenNotPaused {
    _processMultiple(tokens);
  }

  /**
   * @notice Harvests rewards from a given Harvestable contract & process the received rewards
   * @param target Address of the contract to harvest from
   */
  function harvestAndProcess(address target) external nonReentrant whenNotPaused {
    IHarvestable(target).harvest();

    _processMultiple(IHarvestable(target).rewardTokens());
  }

  /**
   * @notice Pulls a token to be swapped to WETH
   * @param token Address of the token to pull
   */
  function pullToken(address token) external nonReentrant whenNotPaused onlyManager {
    _pullToken(token);
  }

  /**
   * @notice Pulls tokens to be swapped to WETH
   * @param tokens List of tokens to pull
   */
  function pullMultipleTokens(address[] calldata tokens) external nonReentrant whenNotPaused onlyManager {
    uint256 length = tokens.length;
    if (length == 0) revert Errors.EmptyArray();

    for (uint256 i; i < length;) {
      _pullToken(tokens[i]);

      unchecked {
        i++;
      }
    }
  }

  /**
   * @notice Claims voting rewards from Quest for the given Locker
   * @param locker Address of the Locker having pending rewards
   * @param distributor Address of the contract distributing the rewards
   * @param claimParams Parameters to claim the rewards
   */
  function claimQuestRewards(address locker, address distributor, IQuestDistributor.ClaimParams[] calldata claimParams)
    external
    nonReentrant
    whenNotPaused
    onlyManager
  {
    if (locker == address(0) || distributor == address(0)) revert Errors.ZeroAddress();

    uint256 length = claimParams.length;
    if (length == 0) revert Errors.EmptyArray();

    for (uint256 i; i < length;) {
      IIncentivizedLocker(locker).claimQuestRewards(
        distributor,
        claimParams[i].questID,
        claimParams[i].period,
        claimParams[i].index,
        locker,
        claimParams[i].amount,
        claimParams[i].merkleProof
      );

      unchecked {
        i++;
      }
    }
  }

  /**
   * @notice Claims voting rewards for the given Locker from the Paladin Delegation address
   * @param locker Address of the Locker having pending rewards
   * @param distributor Address of the contract distributing the rewards
   * @param claimParams Parameters to claim the rewards
   */
  function claimDelegationRewards(
    address locker,
    address distributor,
    IDelegationDistributor.ClaimParams[] calldata claimParams
  ) external nonReentrant whenNotPaused onlyManager {
    if (locker == address(0) || distributor == address(0)) revert Errors.ZeroAddress();

    uint256 length = claimParams.length;
    if (length == 0) revert Errors.EmptyArray();

    for (uint256 i; i < length;) {
      IIncentivizedLocker(locker).claimDelegationRewards(
        distributor,
        claimParams[i].token,
        claimParams[i].index,
        locker,
        claimParams[i].amount,
        claimParams[i].merkleProof
      );

      unchecked {
        i++;
      }
    }
  }

  /**
   * @notice Claims voting rewards from Votium for the given Locker
   * @param locker Address of the Locker having pending rewards
   * @param distributor Address of the contract distributing the rewards
   * @param claimParams Parameters to claim the rewards
   */
  function claimVotiumRewards(address locker, address distributor, IVotiumDistributor.claimParam[] calldata claimParams)
    external
    nonReentrant
    whenNotPaused
    onlyManager
  {
    if (locker == address(0) || distributor == address(0)) revert Errors.ZeroAddress();

    uint256 length = claimParams.length;
    if (length == 0) revert Errors.EmptyArray();

    for (uint256 i; i < length;) {
      IIncentivizedLocker(locker).claimVotiumRewards(
        distributor,
        claimParams[i].token,
        claimParams[i].index,
        locker,
        claimParams[i].amount,
        claimParams[i].merkleProof
      );

      unchecked {
        i++;
      }
    }
  }

  /**
   * @notice Claims voting rewards from HiddenHand for the given Locker
   * @param locker Address of the Locker having pending rewards
   * @param distributor Address of the contract distributing the rewards
   * @param claimParams Parameters to claim the rewards
   */
  function claimHiddenHandRewards(
    address locker,
    address distributor,
    IHiddenHandDistributor.Claim[] memory claimParams
  ) external nonReentrant whenNotPaused onlyManager {
    if (locker == address(0) || distributor == address(0)) revert Errors.ZeroAddress();

    uint256 length = claimParams.length;
    if (length == 0) revert Errors.EmptyArray();

    for (uint256 i; i < length;) {
      IHiddenHandDistributor.Claim[] memory claim = new IHiddenHandDistributor.Claim[](1);
      claim[0] = claimParams[i];
      IIncentivizedLocker(locker).claimHiddenHandRewards(distributor, claim);

      unchecked {
        i++;
      }
    }
  }

  // Internal functions

  /**
   * @dev Processes a token based on their distribution/associated contract & take a fee on the amount processed
   * @param token Address of the token to process
   */
  function _processReward(address token) internal {
    // If the token address is the zero address, skip
    if (token == address(0)) return;

    // Load the token & get the amount to process
    IERC20 _token = IERC20(token);
    uint256 currentBalance = _token.balanceOf(address(this));

    // If the controller doesn't have any, skip
    if (currentBalance == 0) return;

    // Calculate the amount of fees to take
    uint256 feeAmount = (currentBalance * feeRatio) / MAX_BPS;
    uint256 processAmount = currentBalance - feeAmount;

    // Send the fees
    _sendFees(token, feeAmount);

    swapperAmounts[token] += processAmount;

    _pullToken(token);
  }

  /**
   * @dev Processes multiple tokens
   * @param tokens List of tokens to process
   */
  function _processMultiple(address[] memory tokens) internal {
    uint256 length = tokens.length;

    for (uint256 i; i < length;) {
      _processReward(tokens[i]);

      unchecked {
        i++;
      }
    }
  }

  /**
   * @dev Sends the given token to the Swapper
   * @param token Address of the token to send
   */
  function _pullToken(address token) internal {
    uint256 amount = swapperAmounts[token];
    swapperAmounts[token] = 0;

    IERC20(token).safeTransfer(manager, amount);

    emit PullTokens(msg.sender, token, amount);
  }

  /**
   * @dev Sends the given amount of fees to the Fee Receiver
   * @param token Address of the token
   * @param amount Amount of fees to send
   */
  function _sendFees(address token, uint256 amount) internal {
    IERC20(token).safeTransfer(feeReceiver, amount);
  }

  // Admin functions

  /**
   * @notice Pause the contract
   */
  function pause() external onlyOwner {
    _pause();
  }

  /**
   * @notice Unpause the contract
   */
  function unpause() external onlyOwner {
    _unpause();
  }

  /**
   * @notice Updates the Fee Receiver address
   * @param newFeeReceiver Address of the new Fee Receiver
   */
  function setFeeReceiver(address newFeeReceiver) external onlyOwner {
    if (newFeeReceiver == address(0)) revert Errors.ZeroAddress();
    if (newFeeReceiver == feeReceiver) revert Errors.AlreadySet();

    feeReceiver = newFeeReceiver;
  }

  /**
   * @notice Updates the Fee ratio
   * @param newFeeRatio Value (BPS) of the new fee ratio
   */
  function setFeeRatio(uint256 newFeeRatio) external onlyOwner {
    if (newFeeRatio > 1000) revert Errors.InvalidFeeRatio();
    if (newFeeRatio == feeRatio) revert Errors.AlreadySet();

    uint256 oldFeeRatio = feeRatio;
    feeRatio = newFeeRatio;

    emit SetFeeRatio(oldFeeRatio, newFeeRatio);
  }

  function recoverERC20(address _token) external onlyOwner returns (bool) {
    if (_token == address(0)) revert Errors.ZeroAddress();
    uint256 amount = IERC20(_token).balanceOf(address(this));
    if (amount == 0) revert Errors.ZeroValue();

    IERC20(_token).safeTransfer(owner(), amount);

    return true;
  }
}
