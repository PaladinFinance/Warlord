// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

interface IWarRedeem {
  function queuedForWithdrawal() external returns (uint256);
  function notifyUnlock(address token, uint256 amount) external;
}

