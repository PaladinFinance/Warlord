// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {BaseRewardPool} from "interfaces/external/aura/AuraBalStaker.sol";
import {CrvDepositorWrapper} from "interfaces/external/aura/AuraDepositor.sol";
import {IRewards} from "interfaces/external/aura/IRewards.sol";
import "./BaseFarmer.sol";

// TODO test for event emission
contract WarAuraBalFarmer is WarBaseFarmer {
  IERC20 private constant bal = IERC20(0xba100000625a3754423978a60c9317c58a424e3D);
  IERC20 private constant aura = IERC20(0xC0c293ce456fF0ED870ADd98a0828Dd4d2903DBF);
  IERC20 private constant auraBal = IERC20(0x616e8BfA43F920657B3497DBf40D6b1A02D4608d);
  BaseRewardPool private constant auraBalStaker = BaseRewardPool(0x00A7BA8Ae7bca0B10A32Ea1f8e2a1Da980c6CAd2);
  CrvDepositorWrapper private constant balDepositor = CrvDepositorWrapper(0x68655AD9852a99C87C0934c7290BB62CFa5D4123);

  uint256 public slippageBps;

  using SafeERC20 for IERC20;

  constructor(address _controller, address _warStaker) WarBaseFarmer(_controller, _warStaker) {
    // Slippage initial set at 0.5%
    slippageBps = 9950;
  }

  function token() external pure returns (address) {
    return address(auraBal);
  }

  function setSlippage(uint256 _slippageBps) public onlyOwner {
    if (_slippageBps > 500) revert Errors.SlippageTooHigh();
    slippageBps = 10_000 - _slippageBps;
  }

  function stake(address _token, uint256 _amount) external onlyController whenNotPaused nonReentrant {
    if (_token != address(auraBal) && _token != address(bal)) revert Errors.IncorrectToken();
    if (_amount == 0) revert Errors.ZeroValue();

    // TODO test if it works when a bonus is available

    IERC20(_token).safeTransferFrom(controller, address(this), _amount);

    // Variable used to store the amount of BPT created if token is bal
    uint256 stakableAmount = _amount;

    if (_token == address(bal)) {
      uint256 initialBalance = auraBal.balanceOf(address(this));
      bal.safeApprove(address(balDepositor), 0); // TODO should I check here as well for zero approval
      bal.safeIncreaseAllowance(address(balDepositor), _amount);
      uint256 minOut = balDepositor.getMinOut(_amount, slippageBps);
      balDepositor.deposit(_amount, minOut, true, address(0));

      // TODO check if locking bonus is available as in convex
      // Take into account possible bonus for locking crv
      stakableAmount = auraBal.balanceOf(address(this)) - initialBalance;
    }

    _index += stakableAmount;

    auraBal.safeApprove(address(auraBalStaker), 0);
    auraBal.safeIncreaseAllowance(address(auraBalStaker), stakableAmount);
    auraBalStaker.stake(stakableAmount);

    emit Staked(stakableAmount, _index);
  }

  function harvest() external whenNotPaused nonReentrant {
    _harvest();
  }

  function _harvest() internal {
    auraBalStaker.getReward(address(this), true);

    bal.safeTransfer(controller, bal.balanceOf(address(this)));
    aura.safeTransfer(controller, aura.balanceOf(address(this)));

    uint256 extraRewardslength = auraBalStaker.extraRewardsLength();

    for (uint256 i; i < extraRewardslength;) {
      IRewards rewarder = IRewards(auraBalStaker.extraRewards(i));
      IERC20 _token = IERC20(rewarder.rewardToken());
      uint256 balance = _token.balanceOf(address(this));
      _token.transfer(controller, balance);

      unchecked {
        ++i;
      }
    }
  }

  function sendTokens(address receiver, uint256 amount) external onlyWarStaker whenNotPaused nonReentrant {
    if (receiver == address(0)) revert Errors.ZeroAddress();
    if (amount == 0) revert Errors.ZeroValue();
    if (auraBalStaker.balanceOf(address(this)) < amount) revert Errors.UnstakingMoreThanBalance();

    auraBalStaker.withdraw(amount, false);
    auraBal.safeTransfer(receiver, amount);
  }

  function migrate(address receiver) external override onlyOwner whenPaused {
    if (receiver == address(0)) revert Errors.ZeroAddress();

    // Unstake and send cvxCrv
    uint256 auraBalStakedBalance = auraBalStaker.balanceOf(address(this));
    // TODO check that claim does NOT send to the controller
    auraBalStaker.withdraw(auraBalStakedBalance, false);
    auraBal.safeTransfer(receiver, auraBalStakedBalance);

    // Harvest and send rewards to the controller
    _harvest();
  }
}
