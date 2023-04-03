// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import {ERC20} from "openzeppelin/token/ERC20/ERC20.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {AccessControl} from "openzeppelin/access/AccessControl.sol";
import {ReentrancyGuard} from "openzeppelin/security/ReentrancyGuard.sol";
import {Errors} from "utils/Errors.sol";
import {WarStaker} from "./Staker.sol";

contract EscrowedWarToken is ERC20, ReentrancyGuard, AccessControl {
    using SafeERC20 for IERC20;

    // Constants

    /**
     * @notice 1e18 scale
     */
    uint256 private constant UNIT = 1e18;
    /**
     * @notice Max value for BPS - 100%
     */
    uint256 private constant MAX_BPS = 10_000;

    bytes32 public constant WRAP_ROLE = keccak256("WRAP_ROLE");

    // Structs

    /**
     * @notice UserVesting struct
     *   amount: amount being vested
     *   end: vesting end timestamp
     *   claimed: vesting was claimed
     */
    struct UserVesting {
        uint256 amount;
        uint48 end;
        bool claimed;
    }

    /**
     * @notice UserRewardState struct
     *   lastRewardPerToken: last update reward per token value
     *   accruedRewards: total amount of rewards accrued
     */
    struct UserRewardState {
        uint256 lastRewardPerToken;
        uint256 accruedRewards;
    }

    /**
     * @notice RewardState struct
     *   rewardPerToken: current reward per token value
     *   lastUpdate: last state update timestamp
     *   userStates: users reward state for the reward token
     */
    struct RewardState {
        uint256 rewardPerToken;
        uint128 lastUpdate;
        // user address => user reward state
        mapping(address => UserRewardState) userStates;
    }

    /**
     * @notice UserClaimableRewards struct
     *   reward: address of the reward token
     *   claimableAmount: amount of rewards accrued by the user
     */
    struct UserClaimableRewards {
        address reward;
        uint256 claimableAmount;
    }

    /**
     * @notice UserClaimedRewards struct
     *   reward: address of the reward token
     *   amount: amount of rewards claimed by the user
     */
    struct UserClaimedRewards {
        address reward;
        uint256 amount;
    }

    // Storage

    IERC20 public immutable war;
    address public staker;

    address public pendingOwner;
    address public owner;

    address public rewardsReceiver;

    uint256 public clawbackPercent = 5_000; // 50%

    uint256 public vestingDuration = 4_838_400;
    bool public vestingAllowed;

    mapping(address => UserVesting) public vestings;

    mapping(address => RewardState) public rewardStates;

    address[] public rewardTokens;
    mapping(address => bool) private listedRewardTokens;

    // Events

    /**
     * @notice Event emitted when wrapping
     */
    event Wrap(address indexed caller, address indexed receiver, uint256 amount);
    /**
     * @notice Event emitted when unwrapping
     */
    event Unwrap(address indexed owner, address indexed receiver, uint256 amount);
    /**
     * @notice Event emitted when vesting
     */
    event Vesting(address indexed owner, uint256 amount, uint256 end);

    /**
     * @notice Event emitted when rewards are claimed
     */
    event ClaimedRewards(
        address indexed reward,
        address indexed user,
        address indexed receiver,
        uint256 amount
    );

    event RewardsReceiverUpdated(
        address indexed oldReceiver,
        address indexed newReceiver
    );

    event VestingAllowed(bool allowed);

    event VestingDurationUpdated(
        uint256 indexed oldDuration,
        uint256 indexed newDuration
    );

    event NewPendingOwner(
        address indexed previousPendingOwner,
        address indexed newPendingOwner
    );

    // Constructor

    constructor(
        address _war,
        address _staker
    ) ERC20("Warlord escrowed token", "esWAR") {
        if (_war == address(0) || _staker == address(0))
            revert Errors.ZeroAddress();

        owner = msg.sender;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setRoleAdmin(DEFAULT_ADMIN_ROLE, keccak256("NO_ROLE"));

        war = IERC20(_war);
        staker = _staker;

        war.safeApprove(_staker, type(uint256).max);
    }

    // Overrides

    function transfer(
        address /*to*/,
        uint256 /*amount*/
    ) public override(ERC20) returns (bool) {
        revert Errors.CannotTransfer();
    }

    function transferFrom(
        address /*from*/,
        address /*to*/,
        uint256 /*amount*/
    ) public override(ERC20) returns (bool) {
        revert Errors.CannotTransfer();
    }

    // View functions

    /**
     * @notice Get all current claimable amount of rewards for all reward tokens for a given user
     * @param user Address of the user
     * @return UserClaimableRewards[] : Amounts of rewards claimable by reward token
     */
    function getUserTotalClaimableRewards(
        address user
    ) external view returns (UserClaimableRewards[] memory) {
        address[] memory rewards = rewardTokens;
        uint256 rewardsLength = rewards.length;
        UserClaimableRewards[]
            memory rewardAmounts = new UserClaimableRewards[](rewardsLength);

        // For each listed reward
        for (uint256 i; i < rewardsLength; ) {
            // Add the reward token to the list
            rewardAmounts[i].reward = rewards[i];
            // And add the calculated claimable amount of the given reward
            // Accrued rewards from previous stakes + accrued rewards from current stake
            rewardAmounts[i].claimableAmount =
                rewardStates[rewards[i]].userStates[user].accruedRewards +
                _getUserEarnedRewards(rewards[i], user);

            unchecked {
                ++i;
            }
        }
        return rewardAmounts;
    }

    // State changing functions

    function wrap(uint256 amount, address receiver) external nonReentrant onlyRole(WRAP_ROLE) {
        if (amount == 0) revert Errors.ZeroValue();
        if (receiver == address(0)) revert Errors.ZeroAddress();

        IERC20(war).safeTransferFrom(msg.sender, address(this), amount);

        // We want to pull rewards & update the reward states 
        // before minting and increasing the total supply
        _pullRewards();

        WarStaker(staker).stake(amount, address(this));
        _mint(receiver, amount);

        emit Wrap(msg.sender, receiver, amount);
    }

    function vest() external nonReentrant {
        if(!vestingAllowed) revert Errors.VestingNotAllowed();

        uint256 vestingEnd = block.timestamp + vestingDuration;
        uint256 amount = balanceOf(msg.sender);

        if(amount == 0) revert Errors.ZeroValue();

        vestings[msg.sender] = UserVesting({
            amount: amount,
            end: uint48(vestingEnd),
            claimed: false
        });

        emit Vesting(msg.sender, amount, vestingEnd);
    }

    function unwrap(address receiver, bool claim) external nonReentrant {
        UserVesting storage userVesting = vestings[msg.sender];
        if(block.timestamp < userVesting.end) revert Errors.VestingNotFinished();
        if(userVesting.claimed) revert Errors.VestingAlreadyClaimed();

        // We want to pull rewards & update the reward states 
        // before burning and changing the total supply
        _pullRewards();

        if(claim) {
            _claimAllRewards(msg.sender, receiver);
        }

        userVesting.claimed = true;

        uint256 amount = userVesting.amount;

        WarStaker(staker).unstake(amount, receiver);
        _burn(msg.sender, amount);

        emit Unwrap(msg.sender, receiver, amount);
    }

    /**
     * @notice Claim the accrued rewards for a given reward token
     * @param reward Address of the reward token
     * @param receiver Address to receive the rewards
     * @return uint256 : Amount of rewards claimed
     */
    function claimRewards(
        address reward,
        address receiver
    ) external nonReentrant returns (uint256) {
        if (reward == address(0)) revert Errors.ZeroAddress();
        if (receiver == address(0)) revert Errors.ZeroAddress();

        return _claimRewards(reward, msg.sender, receiver);
    }

    /**
     * @notice Claim all accrued rewards for all reward tokens
     * @param receiver Address to receive the rewards
     * @return UserClaimedRewards[] : Amounts of reward claimed
     */
    function claimAllRewards(
        address receiver
    ) external nonReentrant returns (UserClaimedRewards[] memory) {
        if (receiver == address(0)) revert Errors.ZeroAddress();

        return _claimAllRewards(msg.sender, receiver);
    }

    function pullRewards() external nonReentrant {
        _pullRewards();
    }

    // Internal functions

    function _pullRewards() internal {
        WarStaker.UserClaimedRewards[] memory claimed = WarStaker(staker)
            .claimAllRewards(address(this));

        uint256 length = claimed.length;
        for (uint256 i; i < length; i++) {
            address token = claimed[i].reward;
            if (!listedRewardTokens[token]) {
                rewardTokens.push(token);
                listedRewardTokens[token] = true;
            }

            if (claimed[i].amount == 0) continue;

            uint256 clawbackAmount = (claimed[i].amount * clawbackPercent) /
                MAX_BPS;
            IERC20(token).safeTransfer(rewardsReceiver, clawbackAmount);

            uint256 rewardAmount = claimed[i].amount - clawbackAmount;
            _updateRewardState(token, rewardAmount);
        }
    }

    /**
     * @dev Calculate the new rewardPerToken value for a reward token
     * @param reward Address of the reward token
     * @param amount Received amount of the reward token
     * @return uint256 : new rewardPerToken value
     */
    function _getNewRewardPerToken(
        address reward,
        uint256 amount
    ) internal view returns (uint256) {
        RewardState storage state = rewardStates[reward];

        if (state.lastUpdate == block.timestamp) return state.rewardPerToken;

        uint256 totalStakedAmount = totalSupply();
        if (totalStakedAmount == 0) return state.rewardPerToken;

        // Update the rewardPerToken value
        return state.rewardPerToken + ((amount * UNIT) / totalStakedAmount);
    }

    /**
     * @dev Calculate the amount of rewards accrued by an user since last update for a reward token
     * @param reward Address of the reward token
     * @param user Address of the user
     * @return uint256 : Accrued rewards amount for the user
     */
    function _getUserEarnedRewards(
        address reward,
        address user
    ) internal view returns (uint256) {
        uint256 currentRewardPerToken = rewardStates[reward].rewardPerToken;
        UserRewardState storage userState = rewardStates[reward].userStates[
            user
        ];

        // Get the user scaled balance TODO is it correct to talk about scaled balance or does this come from dullahan?
        uint256 userStakedAmount = balanceOf(user);

        if (userStakedAmount == 0) return 0;

        // If the user has a previous deposit (scaled balance is not null), calcualte the
        // earned rewards based on the increase of the rewardPerToken value
        return
            (userStakedAmount *
                (currentRewardPerToken - userState.lastRewardPerToken)) / UNIT;
    }

    /**
     * @dev Update the reward token distribution state
     * @param reward Address of the reward token
     */
    function _updateRewardState(address reward, uint256 amount) internal {
        RewardState storage state = rewardStates[reward];

        // Update the storage with the new reward state
        state.rewardPerToken = _getNewRewardPerToken(reward, amount);
        state.lastUpdate = safe128(block.timestamp);
    }

    /**
     * @dev Update the user reward state for a given reward token
     * @param reward Address of the reward token
     * @param user Address of the user
     */
    function _updateUserRewardState(address reward, address user) internal {
        UserRewardState storage userState = rewardStates[reward].userStates[
            user
        ];

        // Update the storage with the new reward state
        uint256 currentRewardPerToken = rewardStates[reward].rewardPerToken;
        userState.accruedRewards += _getUserEarnedRewards(reward, user);
        userState.lastRewardPerToken = currentRewardPerToken;
    }

    /**
     * @dev Update the reward state of the given user for all the reward tokens
     * @param user Address of the user
     */
    function _updateAllUserRewardStates(address user) internal {
        _pullRewards();

        address[] memory _rewards = rewardTokens;
        uint256 length = _rewards.length;

        // For all reward token in the list, update the user's reward state
        for (uint256 i; i < length; ) {
            _updateUserRewardState(_rewards[i], user);

            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Claims rewards of an user for a given reward token and sends them to the receiver address
     * @param reward Address of reward token
     * @param user Address of the user
     * @param receiver Address to receive the rewards
     * @return uint256 : claimed amount
     */
    function _claimRewards(
        address reward,
        address user,
        address receiver
    ) internal returns (uint256) {
        // Update all user states to get all current claimable rewards
        _updateUserRewardState(reward, user);

        UserRewardState storage userState = rewardStates[reward].userStates[
            user
        ];

        // Fetch the amount of rewards accrued by the user
        uint256 rewardAmount = userState.accruedRewards;

        if (rewardAmount == 0) return 0;

        // Reset user's accrued rewards
        userState.accruedRewards = 0;

        if(reward == address(war)){
            // We want to pull rewards & update the reward states 
            // before minting and increasing the total supply
            _pullRewards();

            WarStaker(staker).stake(rewardAmount, address(this));
            _mint(receiver, rewardAmount);
        } else {
            // If the user accrued rewards, send them to the given receiver
            IERC20(reward).safeTransfer(receiver, rewardAmount);
        }

        emit ClaimedRewards(reward, user, receiver, rewardAmount);

        return rewardAmount;
    }

    /**
     * @dev Claims all rewards of an user and sends them to the receiver address
     * @param user Address of the user
     * @param receiver Address to receive the rewards
     * @return UserClaimedRewards[] : list of claimed rewards
     */
    function _claimAllRewards(
        address user,
        address receiver
    ) internal returns (UserClaimedRewards[] memory) {
        address[] memory rewards = rewardTokens;
        uint256 rewardsLength = rewards.length;

        UserClaimedRewards[] memory rewardAmounts = new UserClaimedRewards[](
            rewardsLength
        );

        // Update all user states to get all current claimable rewards
        _updateAllUserRewardStates(user);

        // For each reward token in the reward list
        for (uint256 i; i < rewardsLength; ) {
            address reward = rewards[i];
            UserRewardState storage userState = rewardStates[reward]
                .userStates[user];

            // Fetch the amount of rewards accrued by the user
            uint256 rewardAmount = userState.accruedRewards;

            // Track the claimed amount for the reward token
            rewardAmounts[i].reward = reward;
            rewardAmounts[i].amount = rewardAmount;

            // If the user accrued no rewards, skip
            if (rewardAmount == 0) continue;

            // Reset user's accrued rewards
            userState.accruedRewards = 0;

            if(reward == address(war)){
                // We want to pull rewards & update the reward states 
                // before minting and increasing the total supply
                _pullRewards();

                WarStaker(staker).stake(rewardAmount, address(this));
                _mint(receiver, rewardAmount);
            } else {
                // If the user accrued rewards, send them to the given receiver
                IERC20(reward).safeTransfer(receiver, rewardAmount);
            }

            emit ClaimedRewards(
                reward,
                user,
                receiver,
                rewardAmount
            );

            unchecked {
                ++i;
            }
        }

        return rewardAmounts;
    }

    // Admin functions

    function transferOwnership(
        address newOwner
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (newOwner == address(0)) revert Errors.ZeroAddress();
        if (newOwner == owner) revert Errors.CannotBeOwner();

        address oldPendingOwner = pendingOwner;

        pendingOwner = newOwner;

        emit NewPendingOwner(oldPendingOwner, newOwner);
    }

    function acceptOwnership() external {
        if (msg.sender != pendingOwner) revert Errors.CallerNotPendingOwner();
        address newOwner = pendingOwner;

        _revokeRole(DEFAULT_ADMIN_ROLE, owner);
        _grantRole(DEFAULT_ADMIN_ROLE, newOwner);

        owner = pendingOwner;
        pendingOwner = address(0);

        emit NewPendingOwner(newOwner, address(0));
    }

    function updateReceiver(
        address newReceiver
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (newReceiver == address(0)) revert Errors.ZeroAddress();
        if (newReceiver == rewardsReceiver) revert Errors.SameAddress();

        address oldReceiver = rewardsReceiver;
        rewardsReceiver = newReceiver;

        emit RewardsReceiverUpdated(oldReceiver, newReceiver);
    }

    function triggerVesting(bool allowed) external onlyRole(DEFAULT_ADMIN_ROLE) {
        vestingAllowed = allowed;

        emit VestingAllowed(allowed);
    }

    function updateVestingDuration(
        uint256 newDuration
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (newDuration == 0) revert Errors.ZeroValue();
        if (newDuration == vestingDuration) revert Errors.AlreadySet();

        uint256 oldDuration = vestingDuration;
        vestingDuration = newDuration;

        emit VestingDurationUpdated(oldDuration, newDuration);
    }

    // Maths

    function safe128(uint256 n) internal pure returns (uint128) {
        if (n > type(uint128).max) revert Errors.NumberExceed128Bits();
        return uint128(n);
    }

    function safe48(uint256 n) internal pure returns (uint48) {
        if (n > type(uint48).max) revert Errors.NumberExceed48Bits();
        return uint48(n);
    }
}
