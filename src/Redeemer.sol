pragma solidity 0.8.16;
//SPDX-License-Identifier: MIT

import {Owner} from "utils/Owner.sol";
import "openzeppelin/token/ERC20/IERC20.sol";
import "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import "openzeppelin/security/Pausable.sol";
import "openzeppelin/security/ReentrancyGuard.sol";
import {Errors} from "utils/Errors.sol";
import {WarToken} from "./Token.sol";
import {IRatios} from "interfaces/IRatios.sol";
import {IWarRedeemModule} from "interfaces/IWarRedeemModule.sol";
import {IWarLocker} from "interfaces/IWarLocker.sol";

/**
 * @title Warlord contract to redeem vlTokens by burning WAR
 * @author xx
 * @notice Redeem vlTokens agaisnt WAR & burn WAR
 */
contract Redeemer is IWarRedeemModule, ReentrancyGuard, Pausable, Owner {
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

  // Struct

  struct TokenIndex {
    uint256 queueIndex;
    uint256 redeemIndex;
  }

  struct RedeemTicket {
    // TODO find better name
    uint256 amount;
    uint256 redeemIndex;
    address token; // TODO #18
    bool redeemed;
  }

  // Storage

  address public immutable war;

  IRatios public ratios;

  address public feeReceiver;

  // token => Locker
  mapping(address => address) public lockers;
  // Locker => token
  mapping(address => address) public lockerTokens;

  uint256 public redeemFee = 500; // 5% in BPS

  mapping(address => TokenIndex) public tokenIndexes;

  // user => token => UserIndexes
  mapping(address => RedeemTicket[]) public userRedeems;

  // Events

  event NewRedeemTicket(address indexed token, address indexed user, uint256 amount, uint256 redeemIndex);

  event Redeemed(address indexed token, address indexed user, address receiver, uint256 indexed ticketNumber);

  event SetWarLocker(address indexed token, address indexed locker);

  event RedeemFeeUpdated(uint256 oldRedeemFee, uint256 newRedeemFee);
  event MintRatioUpdated(address oldMintRatio, address newMintRatio);
  event FeeReceiverUpdated(address oldFeeReceiver, address newFeeReceiver);

  // Constructor

  constructor(address _war, address _ratios, address _feeReceiver, uint256 _redeemFee) {
    if (_war == address(0) || _ratios == address(0) || _feeReceiver == address(0)) revert Errors.ZeroAddress();
    if (_redeemFee == 0 || _redeemFee > 1000) revert Errors.InvalidParameter();

    war = _war;
    ratios = IRatios(_ratios);
    feeReceiver = _feeReceiver;

    redeemFee = _redeemFee;
  }

  // View Functions

  function queuedForWithdrawal(address token) external view returns (uint256) {
    return tokenIndexes[token].queueIndex - tokenIndexes[token].redeemIndex;
  }

  function getUserRedeemTickets(address user) external view returns (RedeemTicket[] memory) {
    return userRedeems[user];
  }

  function getUserActiveRedeemTickets(address user) external view returns (RedeemTicket[] memory) {
    RedeemTicket[] memory _userTickets = userRedeems[user];
    uint256 length = _userTickets.length;
    uint256 activeTickets;

    for (uint256 i; i < length;) {
      if (!_userTickets[i].redeemed) {
        unchecked {
          ++activeTickets;
        }
      }
      unchecked {
        ++i;
      }
    }

    RedeemTicket[] memory activeRedeemTickets = new RedeemTicket[](activeTickets);
    uint256 j;
    for (uint256 i; i < length;) {
      if (!_userTickets[i].redeemed) {
        activeRedeemTickets[j] = _userTickets[i];
        unchecked {
          ++j;
        }
      }
      unchecked {
        ++i;
      }
    }

    return activeRedeemTickets;
  }

  // State Changing Functions

  function notifyUnlock(address token, uint256 amount) external nonReentrant whenNotPaused {
    if (lockerTokens[msg.sender] == address(0)) revert Errors.NotListedLocker();

    tokenIndexes[token].redeemIndex += amount;
  }

  function joinQueue(address[] calldata tokens, uint256[] calldata weights, uint256 amount)
    external
    nonReentrant
    whenNotPaused
  {
    uint256 tokensLength = tokens.length;
    if (tokensLength == 0) revert Errors.EmptyArray();
    if (weights.length != tokensLength) revert Errors.DifferentSizeArrays(tokensLength, weights.length);
    // TODO check percentage sum is 100 ?

    uint256 totalWeight;

    IERC20(war).safeTransferFrom(msg.sender, address(this), amount);

    uint256 feeAmount = (amount * redeemFee) / MAX_BPS;
    uint256 burnAmount = amount - feeAmount;

    IERC20(war).safeTransfer(feeReceiver, feeAmount);
    WarToken(war).burn(address(this), burnAmount);

    for (uint256 i; i < tokensLength;) {
      totalWeight += weights[i];
      if (totalWeight > MAX_BPS) revert Errors.WeightOverflow();

      uint256 warAmount = (burnAmount * weights[i]) / MAX_BPS;
      uint256 redeemAmount = ratios.getBurnAmount(tokens[i], warAmount);

      _joinQueue(tokens[i], msg.sender, redeemAmount);

      unchecked {
        ++i;
      }
    }
  }

  function redeem(uint256[] calldata tickets, address receiver) external nonReentrant whenNotPaused {
    if (receiver == address(0)) revert Errors.ZeroAddress();

    uint256 ticketsLength = tickets.length;
    if (ticketsLength == 0) revert Errors.EmptyArray();

    for (uint256 i; i < ticketsLength;) {
      _redeem(msg.sender, receiver, tickets[i]);

      unchecked {
        ++i;
      }
    }
  }

  // Internal Functions

  function _joinQueue(address token, address user, uint256 amount) internal {
    TokenIndex storage tokenIndex = tokenIndexes[token];

    uint256 newQueueIndex = tokenIndex.queueIndex + amount;
    tokenIndex.queueIndex = newQueueIndex;

    userRedeems[user].push(RedeemTicket({token: token, amount: amount, redeemIndex: newQueueIndex, redeemed: false}));

    emit NewRedeemTicket(token, user, amount, newQueueIndex);
  }

  function _redeem(address user, address receiver, uint256 ticketNumber) internal {
    if (ticketNumber >= userRedeems[user].length) revert Errors.InvalidIndex();

    RedeemTicket storage redeemTicket = userRedeems[user][ticketNumber];
    address token = redeemTicket.token;
    if (redeemTicket.redeemIndex > tokenIndexes[token].redeemIndex) revert Errors.CannotRedeemYet();

    if (redeemTicket.redeemed) revert Errors.AlreadyRedeemed();
    redeemTicket.redeemed = true;

    IERC20(token).safeTransfer(receiver, redeemTicket.amount);

    emit Redeemed(token, user, receiver, ticketNumber);
  }

  // Admin Functions

  function setLocker(address token, address warLocker) external onlyOwner {
    if (token == address(0) || warLocker == address(0)) revert Errors.ZeroAddress();

    address expectedToken = IWarLocker(warLocker).token();
    if (expectedToken != token) revert Errors.MismatchingLocker(expectedToken, token);

    lockers[token] = warLocker;
    lockerTokens[warLocker] = token;

    emit SetWarLocker(token, warLocker);
  }

  function setMintRatio(address newMintRatio) external onlyOwner {
    if (newMintRatio == address(0)) revert Errors.ZeroAddress();

    address oldMintRatio = address(ratios);
    ratios = IRatios(newMintRatio);

    emit MintRatioUpdated(oldMintRatio, newMintRatio);
  }

  function setFeeReceiver(address newFeeReceiver) external onlyOwner {
    if (newFeeReceiver == address(0)) revert Errors.ZeroAddress();

    address oldFeeReceiver = feeReceiver;
    feeReceiver = newFeeReceiver;

    emit FeeReceiverUpdated(oldFeeReceiver, newFeeReceiver);
  }

  function setRedeemFee(uint256 newRedeemFee) external onlyOwner {
    if (newRedeemFee == 0 || newRedeemFee > 1000) revert Errors.InvalidParameter();

    uint256 oldRedeemFee = redeemFee;
    redeemFee = newRedeemFee;

    emit RedeemFeeUpdated(oldRedeemFee, newRedeemFee);
  }

  function pause() external onlyOwner {
    _pause();
  }

  function unpause() external onlyOwner {
    _unpause();
  }

  function recoverERC20(address token) external onlyOwner {
    if (token == address(war) || lockers[token] != address(0)) revert Errors.RecoverForbidden();

    IERC20(token).safeTransfer(owner(), IERC20(token).balanceOf(address(this)));
  }
}
