//██████╗  █████╗ ██╗      █████╗ ██████╗ ██╗███╗   ██╗
//██╔══██╗██╔══██╗██║     ██╔══██╗██╔══██╗██║████╗  ██║
//██████╔╝███████║██║     ███████║██║  ██║██║██╔██╗ ██║
//██╔═══╝ ██╔══██║██║     ██╔══██║██║  ██║██║██║╚██╗██║
//██║     ██║  ██║███████╗██║  ██║██████╔╝██║██║ ╚████║
//╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚═╝╚═╝  ╚═══╝

pragma solidity 0.8.16;
//SPDX-License-Identifier: BUSL-1.1

import {IHolyPaladinToken} from "interfaces/external/IHolyPaladinToken.sol";
import {Owner} from "utils/Owner.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {Pausable} from "openzeppelin/security/Pausable.sol";
import {ReentrancyGuard} from "openzeppelin/security/ReentrancyGuard.sol";
import {Errors} from "utils/Errors.sol";

/**
 * @title Warlord contract distributing WAR to hPAL lockers
 * @author Paladin
 * @notice Distribute WAR to hPAL lockers based on distributions & user's lock status
 */
contract HolyPaladinDistributor is ReentrancyGuard, Pausable, Owner {
  using SafeERC20 for IERC20;

  // Constants

  /**
   * @notice Maximum number of months for a hPAL Lock
   */
  uint256 public constant MAX_NUMBER_MONTHS = 24; // 2 years
  /**
   * @notice Duration of a month
   */
  uint256 public constant MONTH = 2_628_000;

  // Struct

  /**
   * @notice Distribution struct
   *   blockNumber: block number for the distribution checkpoint
   *   timestamp: timestamp for the distribution checkpoint
   *   amount: amount ot be distributed
   *   totalLocked: total locked supply for hPAL
   */
  struct Distribution {
    // TODO #18
    uint256 blockNumber;
    uint256 timestamp; // uint48/64
    uint256 amount; // uint96
    uint256 totalLocked;
  }

  // Storage

  /**
   * @notice Address of the hPAL contract
   */
  IHolyPaladinToken public immutable hPAL;
  /**
   * @notice Address of the WAR token
   */
  IERC20 public immutable war;

  /**
   * @notice Address of the Distribution Manager
   */
  address public distributionManager;

  /**
   * @notice List of distribution checkpoints
   */
  Distribution[] public distributions;

  /**
   * @notice Tracks if users accrued rewards for each distribution
   */
  // User -> Distribution Index -> Claimed
  mapping(address => mapping(uint256 => bool)) userAccrued;
  /**
   * @notice Last distribution index for each user
   */
  mapping(address => uint256) public userLastDistributionIndex;
  /**
   * @notice Amount of tokens accrued for each user
   */
  mapping(address => uint256) public userAccruedAmount;

  /**
   * @notice Total amount not distributed when accruing
   */
  uint256 public totalUndistributedAmount;

  // Events

  /**
   * @notice Event emitted when a new distribution is created
   */
  event DistributionCreated(uint256 indexed distributionIndex, uint256 amount, uint256 totalLocked);

  /**
   * @notice Event emitted when an user claims
   */
  event Claim(address indexed user, address indexed receiver, uint256 amount);

  /**
   * @notice Event emitted when the distribution manager is updated
   */
  event DistributionManagerUpdated(address indexed oldDistributionManager, address indexed newDistributionManager);

  // Modifiers

  /**
   * @notice Checks the caller is the distribution manager
   */
  modifier onlyDistributionManager() {
    // TODO should this be a modifier since it's used only once?
    if (msg.sender != distributionManager) revert Errors.CallerNotAllowed();
    _;
  }

  // Constructor

  constructor(address _hPAL, address _war, address _distributionManager) {
    if (_hPAL == address(0) || _war == address(0) || _distributionManager == address(0)) revert Errors.ZeroAddress();

    hPAL = IHolyPaladinToken(_hPAL);
    war = IERC20(_war);
    distributionManager = _distributionManager;
  }

  // View functions

  /**
   * @notice Returns the current claimable amount for a given user
   * @param user Address of the user
   * @return claimableAmount (uint256) : claimable amount
   */
  function claimable(address user) external view returns (uint256 claimableAmount) {
    claimableAmount = userAccruedAmount[user];

    // Get the current index and the user's last index
    uint256 index = userLastDistributionIndex[user];
    uint256 currentIndex = _currentDistributionIndex();

    // For each distribution not yet accrued for the user
    while (index < currentIndex) {
      // Get the user's amount for the distribution
      (uint256 userAmount,) = _calculateUserClaimAmount(user, index);

      claimableAmount += userAmount;

      unchecked {
        index++;
      }
    }
  }

  // State-changing functions

  /**
   * @notice Creates a new distribution
   * @param amount Amount to be distributed
   */
  function createDistribution(uint256 amount) external nonReentrant onlyDistributionManager whenNotPaused {
    if (amount == 0) revert Errors.ZeroValue();

    // Get the current total locked supply of hPAL
    uint256 totalLocked = hPAL.getCurrentTotalLock().total;
    if (totalLocked == 0) revert Errors.ZeroValue();

    // Pull the tokens
    war.safeTransferFrom(msg.sender, address(this), amount);

    // Add any undistributed amount from previous distributions
    uint256 totalDistributionAmount = amount + totalUndistributedAmount;
    totalUndistributedAmount = 0;

    // Create the distribution
    uint256 distributionIndex = distributions.length;
    distributions.push(
      Distribution({
        blockNumber: block.number,
        timestamp: block.timestamp,
        amount: totalDistributionAmount,
        totalLocked: totalLocked
      })
    );

    emit DistributionCreated(distributionIndex, totalDistributionAmount, totalLocked);
  }

  /**
   * @notice Claim accrued WAR tokens
   * @param receiver Address to receive the tokens
   * @return claimedAmount (uint256) : total amount claimed
   */
  function claim(address receiver) external nonReentrant whenNotPaused returns (uint256 claimedAmount) {
    if (receiver == address(0)) revert Errors.ZeroAddress();

    _updateUserClaimable(msg.sender);

    claimedAmount = userAccruedAmount[msg.sender];
    if (claimedAmount == 0) return 0;

    userAccruedAmount[msg.sender] = 0;
    war.safeTransfer(receiver, claimedAmount);

    emit Claim(msg.sender, receiver, claimedAmount);
  }

  /**
   * @notice Update the user accrued WAR tokens
   * @param user Address of the user to update
   */
  function updateUser(address user) external nonReentrant whenNotPaused {
    _updateUserClaimable(user);
  }

  // Internal functions

  /**
   * @dev Returns the index of the last distribution
   * @return uint256 : current distribution index
   */
  function _currentDistributionIndex() internal view returns (uint256) {
    return distributions.length - 1;
  }

  /**
   * @dev Calculates the user claimable amount for a given distribution
   * @param user Address of the user
   * @param distributionIndex Index of the distribution
   * @return userAmount : Amount of rewards to be distributed to the user
   * @return undistributedAmount : Amount of rewards undistributed to the user
   */
  function _calculateUserClaimAmount(address user, uint256 distributionIndex)
    internal
    view
    returns (uint256 userAmount, uint256 undistributedAmount)
  {
    // Load the Distribution parameters & the user's Lock state at the time of the distribution
    Distribution storage distribution = distributions[distributionIndex];
    IHolyPaladinToken.UserLock memory userLock = hPAL.getUserPastLock(user, distribution.blockNumber);

    if (userLock.amount == 0) return (0, 0);
    // Calculate the end date of the lock
    uint256 endLockDate = userLock.startTimestamp + userLock.duration;
    if (endLockDate < distribution.timestamp) return (0, 0);

    // Get the base amount for the user for this distribution
    uint256 baseAmount = (userLock.amount * distribution.amount) / distribution.totalLocked;

    // Here we want to account for the current started months
    // so we add 1 month to the remaining duration
    uint256 remainingMonths = ((endLockDate - distribution.timestamp) + MONTH) / MONTH;

    // Remove rewards from the amount based on the lock remaining duration
    // (the more the Lock is close to the end, the less rewards the user gets)
    userAmount = (baseAmount * remainingMonths) / MAX_NUMBER_MONTHS;
    undistributedAmount = baseAmount - userAmount;
  }

  /**
   * @dev Accrues user rewards for all distribution not yet accrued
   * @param user Address of the user
   */
  function _updateUserClaimable(address user) internal {
    // Get the current distribution index, and user's last accrued index
    uint256 index = userLastDistributionIndex[user];
    uint256 currentIndex = _currentDistributionIndex();

    uint256 accruedAmount;
    uint256 undistributedAmount;

    // For each distribution not yet accrued for the user
    while (index < currentIndex) {
      // Get the user's amount for the distribution & the undistributed amount
      (uint256 userAmount, uint256 userUndistributedAmount) = _calculateUserClaimAmount(user, index);

      accruedAmount += userAmount;
      undistributedAmount += userUndistributedAmount;

      userAccrued[user][index] = true;

      unchecked {
        index++;
      }
    }

    // Accrue the total amount for the user
    // & set the undistributed amount for future distributions
    userAccruedAmount[user] += accruedAmount;
    totalUndistributedAmount += undistributedAmount;

    // Update the user last index
    userLastDistributionIndex[user] = currentIndex;
  }

  // Admin functions

  /**
   * @notice Updates the Distribution Manager
   * @param newDistributionManager Address of the new Manager
   */
  function updateDistributionManager(address newDistributionManager) external onlyOwner {
    if (newDistributionManager == address(0)) revert Errors.ZeroAddress();
    if (newDistributionManager == distributionManager) revert Errors.SameAddress();

    address oldDistributionManager = distributionManager;
    distributionManager = newDistributionManager;

    emit DistributionManagerUpdated(oldDistributionManager, newDistributionManager);
  }

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
   * @notice Recover ERC2O tokens in the contract
   * @dev Recover ERC2O tokens in the contract
   * @param token Address of the ERC2O token
   */
  function recoverERC20(address token) external onlyOwner {
    if (token == address(war)) revert Errors.RecoverForbidden();

    IERC20(token).safeTransfer(owner(), IERC20(token).balanceOf(address(this)));
  }
}
