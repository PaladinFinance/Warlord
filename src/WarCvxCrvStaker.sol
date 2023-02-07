// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import {IFarmer} from "interfaces/IFarmer.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {Pausable} from "openzeppelin/security/Pausable.sol";
import {Owner} from "utils/Owner.sol";
import {CvxCrvStaker} from "interfaces/external/CvxCrvStaker.sol";
import {Errors} from "utils/Errors.sol";

contract WarCvxCrvStaker is IFarmer, Owner, Pausable {
  IERC20 constant crv = IERC20(0xD533a949740bb3306d119CC777fa900bA034cd52);
  IERC20 constant cvxCrv = IERC20(0x62B9c7356A2Dc64a1969e19C23e4f579F9810Aa7);
  IERC20 constant cvx = IERC20(0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B);
  IERC20 threeCrv = IERC20(0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490);
  CvxCrvStaker constant staker = CvxCrvStaker(0xaa0C3f5F7DFD688C6E646F66CD2a6B66ACdbE434);

  address _controller;
  address _warStaker;
  uint256 _index;

  using SafeERC20 for IERC20;

  event SetController(address controller);
  event SetWarStaker(address warStaker);
  event Staked(uint256 amount, uint256 index);

  constructor(address controller_, address warStaker_) {
    if (controller_ == address(0) || warStaker_ == address(0)) revert Errors.ZeroAddress();
    _controller = controller_;
    _warStaker = warStaker_;
  }

  modifier onlyController() {
    if (_controller != msg.sender) revert Errors.CallerNotAllowed();
    _;
  }

  modifier onlyWarStaker() {
    if (_warStaker != msg.sender) revert Errors.CallerNotAllowed();
    _;
  }

  function controller() public view returns (address) {
    return _controller;
  }

  function warStaker() public view returns (address) {
    return _warStaker;
  }

  function getCurrentIndex() external view returns (uint256) {
    return _index;
  }

  function setController(address controller_) external onlyOwner {
    if (controller_ == address(0)) revert Errors.ZeroAddress();
    if (controller_ == _controller) revert Errors.AlreadySet();
    _controller = controller_;

    emit SetController(controller_);
  }

  function setWarStaker(address warStaker_) external onlyOwner {
    if (warStaker_ == address(0)) revert Errors.ZeroAddress();
    if (warStaker_ == _warStaker) revert Errors.AlreadySet();
    _warStaker = warStaker_;

    emit SetWarStaker(warStaker_);
  }

  function setRewardWeight(uint256 weight) external onlyOwner whenNotPaused {
    staker.setRewardWeight(weight);
  }

  function stake(address source, uint256 amount) external onlyController whenNotPaused {
    if (source != address(cvxCrv) && source != address(crv)) revert Errors.IncorrectToken();
    if (amount == 0) revert Errors.ZeroValue();

    _index += amount;

    IERC20(source).safeTransferFrom(_controller, address(this), amount);
    IERC20(source).safeApprove(address(staker), amount);
    if (source == address(crv)) staker.deposit(amount, address(this));
    else if (source == address(cvxCrv)) staker.stake(amount, address(this));

    emit Staked(amount, _index);
  }

  function harvest() external whenNotPaused {
    _harvest();
  }

  function _harvest() internal {
    staker.getReward(address(this), _controller);
  }

  function sendTokens(address receiver, uint256 amount) external onlyWarStaker whenNotPaused {
    if (receiver == address(0)) revert Errors.ZeroAddress();
    if (amount == 0) revert Errors.ZeroValue();
    if (staker.balanceOf(address(this)) < amount) revert Errors.UnstakingMoreThanBalance();

    staker.withdraw(amount);
    cvxCrv.safeTransfer(receiver, amount);
  }

  function migrate(address receiver) external onlyOwner whenPaused {
    if (receiver == address(0)) revert Errors.ZeroAddress();

    // Unstake and send cvxCrv
    uint256 cvxCrvStakedBalance = staker.balanceOf(address(this));
    staker.withdraw(cvxCrvStakedBalance);
    cvxCrv.safeTransfer(receiver, cvxCrvStakedBalance);

    // Harvest and send rewards to the controller
    _harvest();
  }

  function pause() external onlyOwner {
    _pause();
  }

  function unpause() external onlyOwner {
    _unpause();
  }
}
