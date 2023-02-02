// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

interface IMintRatio {
  function computeMintAmount(address token, uint256 amount) external view returns (uint256 mintAmount);
}
