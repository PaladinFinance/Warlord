// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "interfaces/IWarRedeemModule.sol";
import "utils/Owner.sol";

contract MockRedeem is IWarRedeemModule, Owner {
  uint256 queued;

  function queuedForWithdrawal() external view returns (uint256) {
    return queued;
  }

  function notifyUnlock(address token, uint256 amount) external {
    // TODO restrict call by processUnlock
    if (token != address(0)) {
      queued -= amount;
    }
  }

  // Mock function for testing purposes
  function setQueue(uint256 amount) external {
    queued = amount;
  }
}
