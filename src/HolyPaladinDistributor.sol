pragma solidity 0.8.16;
//SPDX-License-Identifier: MIT

import "interfaces/external/IHolyPaladinToken.sol";
import {Owner} from "utils/Owner.sol";
import "openzeppelin/token/ERC20/IERC20.sol";
import "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import "openzeppelin/security/Pausable.sol";
import "openzeppelin/security/ReentrancyGuard.sol";
import {Errors} from "utils/Errors.sol";

/**
 * @title Warlord contract distributing WAR to hPAL lockers
 * @author xx
 * @notice Distribute WAR to hPAL lockers based on distributions & user's lock status
 */
contract HolyPaladinDistributor is ReentrancyGuard, Pausable, Owner {
    using SafeERC20 for IERC20;

    // Constants

    /** @notice Maximum number of months for a hPAL Lock  */
    uint256 public constant MAX_NUMBER_MONTHS = 24; // 2 years
    /** @notice Duration of a month */
    uint256 public constant MONTH = 2628000;

    // Struct 

    struct Distribution {
        uint256 blockNumber;
        uint256 timestamp;
        uint256 amount;
        uint256 totalLocked;
    }


    // Storage

    IHolyPaladinToken public immutable hPAL;
    IERC20 public immutable war;

    address public distributionManager;

    Distribution[] public distributions;

    // User -> Distribution Index -> Claimed
    mapping(address => mapping(uint256 => bool)) userAccrued;
    mapping(address => uint256) public userLastDistributionIndex;
    mapping(address => uint256) public userAccruedAmount;

    uint256 public totalUndistributedAmount;


    // Events

    event DistributionCreated(uint256 indexed distributionIndex, uint256 amount, uint256 totalLocked);

    event Claim(address indexed user, address indexed receiver, uint256 amount);

    event DistributionManagerUpdated(address indexed oldDistributionManager, address indexed newDistributionManager);


    // Modifiers

    modifier onlyDistributionManager() {
        if(msg.sender != distributionManager) revert Errors.CallerNotAllowed();
        _;
    }


    // Constructor

    constructor(address _hPAL, address _war, address _distributionManager) {
        if(_hPAL == address(0) || _war == address(0) || _distributionManager == address(0)) revert Errors.ZeroAddress();

        hPAL = IHolyPaladinToken(_hPAL);
        war = IERC20(_war);
        distributionManager = _distributionManager;
    }


    // View functions

    function claimable(address user) external view returns(uint256 claimableAmount) {
        claimableAmount = userAccruedAmount[user];

        uint256 index = userLastDistributionIndex[user];
        uint256 currentIndex = _currentDistributionIndex();

        while(index < currentIndex) {
            (uint256 userAmount,) = _calculateUserClaimAmount(user, index);

            claimableAmount += userAmount;

            unchecked { index++; }
        }
    }


    // State-changing functions

    function createDistribution(uint256 amount) external nonReentrant onlyDistributionManager whenNotPaused {
        if(amount == 0) revert Errors.ZeroValue();

        uint256 totalLocked = hPAL.getCurrentTotalLock().total;
        if(totalLocked == 0) revert Errors.ZeroValue();

        war.safeTransferFrom(msg.sender, address(this), amount);

        uint256 totalDistributionAmount = amount + totalUndistributedAmount;
        totalUndistributedAmount = 0;

        uint256 distributionIndex = distributions.length;
        distributions.push(Distribution({
            blockNumber: block.number,
            timestamp: block.timestamp,
            amount: totalDistributionAmount,
            totalLocked: totalLocked
        }));

        emit DistributionCreated(distributionIndex, totalDistributionAmount, totalLocked);
    }
    
    function claim(address user, address receiver) external nonReentrant whenNotPaused returns(uint256 claimedAmount) {
        if(user == address(0) || receiver == address(0)) revert Errors.ZeroAddress();

        _updateUserClaimable(user);

        claimedAmount = userAccruedAmount[user];
        if(claimedAmount == 0) return 0;

        userAccruedAmount[user] = 0;
        war.safeTransfer(receiver, claimedAmount);

        emit Claim(user, receiver, claimedAmount);
    }
    
    function updateUser(address user) external nonReentrant whenNotPaused {
        _updateUserClaimable(user);
    }


    // Internal functions

    function _currentDistributionIndex() internal view returns(uint256) {
        return distributions.length - 1;
    }

    function _calculateUserClaimAmount(
        address user,
        uint256 distributionIndex
    ) internal view returns(
        uint256 userAmount,
        uint256 undistributedAmount
    ) {
        Distribution storage distribution = distributions[distributionIndex];
        IHolyPaladinToken.UserLock memory userLock = hPAL.getUserPastLock(user, distribution.blockNumber);

        if(userLock.amount == 0) return (0, 0);
        uint256 endLockDate = userLock.startTimestamp + userLock.duration;
        if(endLockDate < distribution.timestamp) return (0, 0);

        uint256 baseAmount = (userLock.amount * distribution.amount) / distribution.totalLocked;

        // Here we want to account for the current started months
        // so we add 1 month to the remaining duration
        uint256 reaminingMonths = ((endLockDate - distribution.timestamp) + MONTH) / MONTH;

        userAmount = (baseAmount * reaminingMonths) / MAX_NUMBER_MONTHS;
        undistributedAmount = baseAmount - userAmount;
    }

    function _updateUserClaimable(address user) internal {
        uint256 index = userLastDistributionIndex[user];
        uint256 currentIndex = _currentDistributionIndex();

        uint256 accruedAmount;
        uint256 undistributedAmount;

        while(index < currentIndex) {
            (uint256 userAmount, uint256 userUndistributedAmount) = _calculateUserClaimAmount(user, index);

            accruedAmount += userAmount;
            undistributedAmount += userUndistributedAmount;

            userAccrued[user][index] = true;

            unchecked { index++; }
        }

        userAccruedAmount[user] += accruedAmount;
        totalUndistributedAmount += undistributedAmount;

        userLastDistributionIndex[user] = currentIndex;
    }


    // Admin functions

    function updateDistributionManager(address newDistributionManager) external onlyOwner {
        if(newDistributionManager == address(0)) revert Errors.ZeroAddress();
        if(newDistributionManager == distributionManager) revert Errors.SameAddress();

        address oldDistributionManager = distributionManager;
        distributionManager = newDistributionManager;

        emit DistributionManagerUpdated(oldDistributionManager, newDistributionManager);
    }

}