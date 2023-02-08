// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import {IFarmer} from "interfaces/IFarmer.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {Pausable} from "openzeppelin/security/Pausable.sol";
import {Owner} from "utils/Owner.sol";
import {CvxCrvStaker} from "interfaces/external/CvxCrvStaker.sol";
import {Errors} from "utils/Errors.sol";
import {ReentrancyGuard} from "solmate/utils/ReentrancyGuard.sol";

contract WarCvxCrvStaker is IFarmer, Owner, Pausable, ReentrancyGuard {
  IERC20 private constant crv = IERC20(0xD533a949740bb3306d119CC777fa900bA034cd52);
  IERC20 private constant cvxCrv = IERC20(0x62B9c7356A2Dc64a1969e19C23e4f579F9810Aa7);
  IERC20 private constant cvx = IERC20(0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B);
  IERC20 private constant threeCrv = IERC20(0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490);
  CvxCrvStaker private constant staker = CvxCrvStaker(0xaa0C3f5F7DFD688C6E646F66CD2a6B66ACdbE434);

  address public controller;
  address public warStaker;
  uint256 private _index;

  using SafeERC20 for IERC20;

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

  function getCurrentIndex() external view returns (uint256) {
    return _index;
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

  function setRewardWeight(uint256 weight) external onlyOwner whenNotPaused {
    staker.setRewardWeight(weight);
  }

  function stake(address token, uint256 amount) external onlyController whenNotPaused nonReentrant {
    if (token != address(cvxCrv) && token != address(crv)) revert Errors.IncorrectToken();
    if (amount == 0) revert Errors.ZeroValue();

    _index += amount;

    IERC20(token).safeTransferFrom(controller, address(this), amount);
    IERC20(token).safeApprove(address(staker), amount);
    if (token == address(crv)) staker.deposit(amount, address(this)); // TODO fix this to prevent fees from increase

    else if (token == address(cvxCrv)) staker.stake(amount, address(this));

    emit Staked(amount, _index);
  }

  function harvest() external whenNotPaused nonReentrant {
    _harvest();
  }

  function _harvest() internal {
    staker.getReward(address(this), controller);
  }

  function sendTokens(address receiver, uint256 amount) external onlyWarStaker whenNotPaused nonReentrant {
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
