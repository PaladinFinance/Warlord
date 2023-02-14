// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {BaseRewardPool} from "interfaces/external/AuraBalStaker.sol";
import {CrvDepositorWrapper} from "interfaces/external/AuraDepositor.sol";
import "./WarBaseFarmer.sol";

// TODO test for event emission
contract WarAuraBalFarmer is WarBaseFarmer {
  IERC20 private constant bal = IERC20(0xba100000625a3754423978a60c9317c58a424e3D);
  IERC20 private constant auraBal = IERC20(0x616e8BfA43F920657B3497DBf40D6b1A02D4608d);
  BaseRewardPool constant auraBalStaking = BaseRewardPool(0x00A7BA8Ae7bca0B10A32Ea1f8e2a1Da980c6CAd2);
  CrvDepositorWrapper private constant balDepositor = CrvDepositorWrapper(0x68655AD9852a99C87C0934c7290BB62CFa5D4123);

  uint256 public slippageBps;

  using SafeERC20 for IERC20;

  constructor(address _controller, address _warStaker) WarBaseFarmer(_controller, _warStaker) {}

  function setSlippage(uint256 _slippageBps) public onlyOwner {
    if (_slippageBps > 500) revert Errors.SlippageTooHigh();
    slippageBps = 10_000 - _slippageBps;
  }

  function stake(address token, uint256 amount) external onlyController whenNotPaused nonReentrant {
    if (token != address(auraBal) && token != address(bal)) revert Errors.IncorrectToken();
    if (amount == 0) revert Errors.ZeroValue();

    // TODO test if it works when a bonus is available

    IERC20(token).safeTransferFrom(controller, address(this), amount);

    // Variable used to store the amount of BPT created if token is bal
    uint256 stakableAmount = amount;

    if (token == address(bal)) {
      uint256 initialBalance = auraBal.balanceOf(address(this));
      bal.safeApprove(address(balDepositor), amount);
      uint256 minOut = balDepositor.getMinOut(amount, slippageBps);
      balDepositor.deposit(amount, minOut, true, address(0));

      // TODO check if locking bonus is available as in convex
      // Take into account possible bonus for locking crv
      stakableAmount = auraBal.balanceOf(address(this)) - initialBalance;
    }

    _index += stakableAmount;

    auraBal.safeApprove(address(auraBalStaking), stakableAmount);
    auraBalStaking.stake(stakableAmount);

    emit Staked(amount, _index);
  }

  function harvest() external whenNotPaused nonReentrant {
    _harvest();
  }

  function _harvest() internal {
    auraBalStaking.getReward(controller, false);
  }

  function sendTokens(address receiver, uint256 amount) external onlyWarStaker whenNotPaused nonReentrant {
    if (receiver == address(0)) revert Errors.ZeroAddress();
    if (amount == 0) revert Errors.ZeroValue();
    if (auraBalStaking.balanceOf(address(this)) < amount) revert Errors.UnstakingMoreThanBalance();

    auraBalStaking.withdraw(amount, false);
    auraBal.safeTransfer(receiver, amount);
  }

  function migrate(address receiver) external override onlyOwner whenPaused {
    if (receiver == address(0)) revert Errors.ZeroAddress();

    // Unstake and send cvxCrv
    uint256 auraBalStakedBalance = auraBalStaking.balanceOf(address(this));
    // TODO check that claim does NOT send to the controller
    auraBalStaking.withdraw(auraBalStakedBalance, false);
    auraBal.safeTransfer(receiver, auraBalStakedBalance);

    // Harvest and send rewards to the controller
    _harvest();
  }
}