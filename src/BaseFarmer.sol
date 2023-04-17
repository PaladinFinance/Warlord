//██████╗  █████╗ ██╗      █████╗ ██████╗ ██╗███╗   ██╗
//██╔══██╗██╔══██╗██║     ██╔══██╗██╔══██╗██║████╗  ██║
//██████╔╝███████║██║     ███████║██║  ██║██║██╔██╗ ██║
//██╔═══╝ ██╔══██║██║     ██╔══██║██║  ██║██║██║╚██╗██║
//██║     ██║  ██║███████╗██║  ██║██████╔╝██║██║ ╚████║
//╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚═╝╚═╝  ╚═══╝

pragma solidity 0.8.16;
//SPDX-License-Identifier: BUSL-1.1

import {Harvestable} from "./Harvestable.sol";
import {Owner} from "utils/Owner.sol";
import {Errors} from "utils/Errors.sol";
import {Pausable} from "openzeppelin/security/Pausable.sol";
import {IFarmer} from "interfaces/IFarmer.sol";
import {ReentrancyGuard} from "solmate/utils/ReentrancyGuard.sol";

abstract contract WarBaseFarmer is IFarmer, Owner, Pausable, ReentrancyGuard, Harvestable {
  address public controller;
  address public warStaker;

  uint256 internal _index;

  event SetController(address controller);
  event SetWarStaker(address warStaker);
  event Staked(uint256 amount);

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

  function _isTokenSupported(address _token) internal virtual returns (bool);

  function _stake(address _token, uint256 _amount) internal virtual returns (uint256);

  function stake(address _token, uint256 _amount) external nonReentrant onlyController whenNotPaused {
    if (!_isTokenSupported(_token)) revert Errors.IncorrectToken();
    if (_amount == 0) revert Errors.ZeroValue();

    // Staked amount may change from iniital argument when wrapping BAL into auraBAL
    uint256 amountStaked = _stake(_token, _amount);

    emit Staked(amountStaked);
  }

  function _harvest() internal virtual;

  function harvest() external nonReentrant whenNotPaused {
    _harvest();
  }

  function getCurrentIndex() external view returns (uint256) {
    return _index;
  }

  function _stakedBalance() internal virtual returns (uint256);

  function _sendTokens(address receiver, uint256 amount) internal virtual;

  function sendTokens(address receiver, uint256 amount) external nonReentrant onlyWarStaker whenNotPaused {
    if (receiver == address(0)) revert Errors.ZeroAddress();
    if (amount == 0) revert Errors.ZeroValue();
    if (_stakedBalance() < amount) revert Errors.UnstakingMoreThanBalance();

    _sendTokens(receiver, amount);
  }

  function _migrate(address receiver) internal virtual;

  function migrate(address receiver) external nonReentrant onlyOwner whenPaused {
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
