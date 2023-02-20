// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./BaseLocker.sol";
import {AuraLocker} from "interfaces/external/aura/vlAura.sol";
import {Math} from "openzeppelin/utils/math/Math.sol";

contract WarAuraLocker is WarBaseLocker {
  IERC20 constant aura = IERC20(0xC0c293ce456fF0ED870ADd98a0828Dd4d2903DBF);
  AuraLocker constant vlAura = AuraLocker(0x3Fa73f1E5d8A792C80F426fc8F84FBF7Ce9bBCAC);

  using SafeERC20 for IERC20;

  constructor(address _controller, address _redeemModule, address _warMinter, address _delegatee)
    WarBaseLocker(_controller, _redeemModule, _warMinter, _delegatee)
  {}

  function token() external pure returns (address) {
    return address(aura);
  }

  function _lock(uint256 amount) internal override {
    if (amount == 0) revert Errors.ZeroValue();

    aura.safeTransferFrom(msg.sender, address(this), amount);

    aura.safeApprove(address(vlAura), 0);
    aura.safeIncreaseAllowance(address(vlAura), amount);

    vlAura.lock(address(this), amount);
  }

  function _harvest() internal override {
    AuraLocker.EarnedData[] memory rewards = vlAura.claimableRewards(address(this));
    uint256 rewardsLength = rewards.length;

    vlAura.getReward(address(this), false);

    for (uint256 i; i < rewardsLength;) {
      // TODO is it cheaper with a variable assignment instead of array access twice?
      IERC20(rewards[i].token).safeTransfer(controller, rewards[i].amount);

      unchecked {
        ++i;
      }
    }
  }

  function _processUnlock() internal override {
    _harvest();

    (, uint256 unlockableBalance,,) = vlAura.lockedBalances(address(this));
    if (unlockableBalance == 0) return;

    uint256 withdrawalAmount = IWarRedeemModule(redeemModule).queuedForWithdrawal();

    // If unlock == 0 relock everything
    if (withdrawalAmount == 0) {
      vlAura.processExpiredLocks(true);
      return;
    } else {
      // otherwise withdraw everything and lock only what's left
      vlAura.processExpiredLocks(false);
      withdrawalAmount = Math.min(unlockableBalance, withdrawalAmount);
      aura.transfer(address(redeemModule), withdrawalAmount);
      IWarRedeemModule(redeemModule).notifyUnlock(address(aura), withdrawalAmount);

      // TODO are variable assignment that expensive gas wise
      uint256 relock = unlockableBalance - withdrawalAmount;
      aura.safeApprove(address(vlAura), 0);
      aura.safeIncreaseAllowance(address(vlAura), relock);
      vlAura.lock(address(this), relock);
    }
  }

  function _migrate(address receiver) internal override {
    if (!vlAura.isShutdown() && !isShutdown) revert Errors.LockerStillAlive();

    // withdraws unlockable balance to receiver
    vlAura.processExpiredLocks(false);
    uint256 unlockedBalance = aura.balanceOf(address(this));
    aura.transfer(receiver, unlockedBalance);

    // withdraws rewards to controller
    _harvest();
  }
}
