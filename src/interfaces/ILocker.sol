// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

interface ILocker {
  function migrate(address receiver) external;
  function transferOwnership(address newOwner) external;
  function acceptOwnership() external;
  function paused() external view returns (bool)
}
