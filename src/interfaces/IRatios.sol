// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

interface IRatios {
  function addTokenWithSupply(address token, uint256 maxSupply) external;
  function getMintAmount(address token, uint256 amount) external view returns (uint256 mintAmount);
  function getBurnAmount(address token, uint256 amount) external view returns (uint256 burnAmount);
}
