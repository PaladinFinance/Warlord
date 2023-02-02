// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./MintRatioTest.sol";

contract ComputeMintAmount is MintRatioTest {
  function testMintAmount() public {
    mintRatio.computeMintAmount(address(cvx), 100_000_000);
    mintRatio.computeMintAmount(address(cvx), 100_000_000);
  }
}
