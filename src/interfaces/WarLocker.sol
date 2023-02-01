// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

interface WarLocker {
  function lock(uint256 amount) external;
  function token() external view returns (address);
}
