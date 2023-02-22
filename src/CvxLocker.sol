// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./BaseLocker.sol";
import {IDelegateRegistry} from "interfaces/external/IDelegateRegistry.sol";
import {CvxLockerV2} from "interfaces/external/convex/vlCvx.sol";
import {Math} from "openzeppelin/utils/math/Math.sol";

contract WarCvxLocker is WarBaseLocker {
  CvxLockerV2 private constant vlCvx = CvxLockerV2(0x72a19342e8F1838460eBFCCEf09F6585e32db86E);
  IERC20 private constant cvx = IERC20(0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B);
  IDelegateRegistry private constant registry = IDelegateRegistry(0x469788fE6E9E9681C6ebF3bF78e7Fd26Fc015446);

  using SafeERC20 for IERC20;

  constructor(address _controller, address _redeemModule, address _warMinter, address _delegatee)
    WarBaseLocker(_controller, _redeemModule, _warMinter, _delegatee)
  {
    registry.setDelegate("cvx.eth", _delegatee);
  }

  function token() external pure returns (address) {
    return address(cvx);
  }

  function _lock(uint256 amount) internal override {
    cvx.safeTransferFrom(msg.sender, address(this), amount);

    cvx.safeApprove(address(vlCvx), 0);
    cvx.safeIncreaseAllowance(address(vlCvx), amount);

    vlCvx.lock(address(this), amount, 0); // TODO what is _spendRatio
  }

  function _harvest() internal override {
    CvxLockerV2.EarnedData[] memory rewards = vlCvx.claimableRewards(address(this));
    uint256 rewardsLength = rewards.length;

    vlCvx.getReward(address(this), false);

    for (uint256 i; i < rewardsLength;) {
      IERC20 rewardToken = IERC20(rewards[i].token);
      uint256 rewardBalance = rewardToken.balanceOf(address(this));
      rewardToken.safeTransfer(controller, rewardBalance);

      unchecked {
        ++i;
      }
    }
  }

  function setDelegate(address _delegatee) external onlyOwner {
    delegatee = _delegatee;
    registry.setDelegate("cvx.eth", _delegatee);
  }

  function _processUnlock() internal override {
    _harvest();

    (, uint256 unlockableBalance,,) = vlCvx.lockedBalances(address(this));
    if (unlockableBalance == 0) return;

    uint256 withdrawalAmount = IWarRedeemModule(redeemModule).queuedForWithdrawal();

    // If unlock == 0 relock everything
    if (withdrawalAmount == 0) {
      vlCvx.processExpiredLocks(true);
    } else {
      // otherwise withdraw everything and lock only what's left
      vlCvx.processExpiredLocks(false);
      withdrawalAmount = Math.min(unlockableBalance, withdrawalAmount);
      cvx.transfer(address(redeemModule), withdrawalAmount);
      IWarRedeemModule(redeemModule).notifyUnlock(address(cvx), withdrawalAmount);

      // TODO are variable assignment that expensive gas wise
      uint256 relock = unlockableBalance - withdrawalAmount;
      cvx.safeApprove(address(vlCvx), 0);
      cvx.safeIncreaseAllowance(address(vlCvx), relock);
      vlCvx.lock(address(this), relock, 0);
    }
  }

  function _migrate(address receiver) internal override {
    if (!vlCvx.isShutdown() && !isShutdown) revert Errors.LockerStillAlive();

    // withdraws unlockable balance to receiver
    vlCvx.withdrawExpiredLocksTo(receiver);

    // withdraws rewards to controller
    _harvest();
  }
}
