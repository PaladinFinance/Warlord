// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import {Owner} from "utils/Owner.sol";
import {Errors} from "utils/Errors.sol";
import {Pausable} from "openzeppelin/security/Pausable.sol";
import {IFarmer} from "interfaces/IFarmer.sol";
import {ReentrancyGuard} from "solmate/utils/ReentrancyGuard.sol";

// TODO enforce modifiers here
abstract contract WarBaseFarmer is IFarmer, Owner, Pausable, ReentrancyGuard {
  address public controller;
  address public warStaker;

  uint256 internal _index;

  event SetController(address controller);
  event SetWarStaker(address warStaker);
  event Staked(uint256 amount, uint256 index);

  constructor(address _controller, address _warStaker) {
    if (_controller == address(0) || _warStaker == address(0)) revert Errors.ZeroAddress();
    controller = _controller;
    warStaker = _warStaker;
  }

  modifier onlyController() {
    if (controller != msg.sender) revert Errors.CallerNotAllowed();
    _;
  }

  modifier onlyWarStaker() {
    if (warStaker != msg.sender) revert Errors.CallerNotAllowed();
    _;
  }

  function _isTokenSupported(address _token) virtual internal returns (bool);

  function _stake(address _token, uint256 _amount) virtual internal returns (uint256);
  function stake(address _token, uint256 _amount) external onlyController whenNotPaused nonReentrant {
    if (!_isTokenSupported(_token)) revert Errors.IncorrectToken();
    if (_amount == 0) revert Errors.ZeroValue();

    uint256 amountStaked = _stake(_token, _amount);

    emit Staked(amountStaked, _index);
  }

  function _harvest() virtual internal;

  function harvest() external whenNotPaused nonReentrant {
    _harvest();
  }

  function getCurrentIndex() external view returns (uint256) {
    return _index;
  }

  function _stakedBalance() internal virtual returns (uint256);

  function _sendTokens() internal virtual;
  function sendTokens(address receiver, uint256 amount) external onlyWarStaker whenNotPaused nonReentrant {
    if (receiver == address(0)) revert Errors.ZeroAddress();
    if (amount == 0) revert Errors.ZeroValue();
    if (_stakedBalance() < amount) revert Errors.UnstakingMoreThanBalance();

    _sendTokens();
  }

  function _migrate(address receiver) internal virtual;

  function migrate(address receiver) external onlyOwner whenPaused {
    if (receiver == address(0)) revert Errors.ZeroAddress();

    _migrate(receiver);

    // Harvest and send rewards to the controller
    _harvest();
  }

  function setController(address _controller) external onlyOwner {
    if (_controller == address(0)) revert Errors.ZeroAddress();
    if (_controller == controller) revert Errors.AlreadySet();
    controller = _controller;

    emit SetController(_controller);
  }

  function setWarStaker(address _warStaker) external onlyOwner {
    if (_warStaker == address(0)) revert Errors.ZeroAddress();
    if (_warStaker == warStaker) revert Errors.AlreadySet();
    warStaker = _warStaker;

    emit SetWarStaker(_warStaker);
  }

  function pause() external onlyOwner {
    _pause();
  }

  function unpause() external onlyOwner {
    _unpause();
  }
}
