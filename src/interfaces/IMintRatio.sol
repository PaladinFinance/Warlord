// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

interface IMintRatio {
  function addTokenWithSupply(address token, uint256 maxSupply) external;
  function computeMintAmount(address token, uint256 amount) external view returns (uint256 mintAmount);
}
