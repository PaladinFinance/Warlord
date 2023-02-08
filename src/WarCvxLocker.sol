// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import {IWarLocker} from "interfaces/IWarLocker.sol";
import {IDelegateRegistry} from "interfaces/external/IDelegateRegistry.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {Pausable} from "openzeppelin/security/Pausable.sol";
import {ReentrancyGuard} from "solmate/utils/ReentrancyGuard.sol";
import {SafeERC20} from "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {CvxLockerV2} from "interfaces/external/vlCvx.sol";
import {Owner} from "utils/Owner.sol";
import {Errors} from "utils/Errors.sol";
import {IWarRedeemModule} from "interfaces/IWarRedeemModule.sol";
import {Math} from "openzeppelin/utils/math/Math.sol";

contract WarCvxLocker is IWarLocker, Pausable, Owner, ReentrancyGuard {
  CvxLockerV2 private constant locker = CvxLockerV2(0x72a19342e8F1838460eBFCCEf09F6585e32db86E);
  IERC20 private constant cvx = IERC20(0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B);
  IDelegateRegistry public constant registry = IDelegateRegistry(0x469788fE6E9E9681C6ebF3bF78e7Fd26Fc015446);

  IWarRedeemModule public redeemModule;
  address public controller;
  // TODO should I make a variable for the delegatee

  using SafeERC20 for IERC20;

  constructor(address _controller, address _redeemModule, address _delegatee) {
    if (_controller == address(0) || _redeemModule == address(0)) revert Errors.ZeroAddress();
    controller = _controller;
    redeemModule = IWarRedeemModule(_redeemModule);
    registry.setDelegate("cvx.eth", _delegatee);
  }

  function token() external pure returns (address) {
    return address(cvx);
  }

  function lock(uint256 amount) public {
    if (amount == 0) revert Errors.ZeroValue();

    cvx.safeTransferFrom(msg.sender, address(this), amount);
    cvx.safeApprove(address(locker), amount);
    locker.lock(address(this), amount, 0); // TODO what is _spendRatio
  }

  function harvest() public {
    locker.getReward(controller);
  }

  function delegate(address delegatee) external onlyOwner {
    registry.setDelegate("cvx.eth", delegatee);
  }

  function processUnlock() external {
    harvest();

    (, uint256 unlockableBalance,,) = locker.lockedBalances(address(this));
    if (unlockableBalance == 0) return;

    uint256 withdrawalAmount = redeemModule.queuedForWithdrawal();

    // If unlock == 0 relock, otherwise withdraw everything and lock only what's left
    if (withdrawalAmount == 0) {
      locker.processExpiredLocks(true);
      return;
    } else {
      locker.processExpiredLocks(false);
      withdrawalAmount = Math.min(unlockableBalance, withdrawalAmount);
      cvx.transfer(address(redeemModule), withdrawalAmount);
      redeemModule.notifyUnlock(address(cvx), withdrawalAmount);

      uint256 relock = unlockableBalance - withdrawalAmount;
      cvx.safeApprove(address(locker), relock);
      lock(relock);
    }
  }
}
