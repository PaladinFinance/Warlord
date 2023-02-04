// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "../MainnetTest.sol";
import "../../src/WarMintRatio.sol";

contract MintRatioTest is MainnetTest {
  IMintRatio mintRatio;
  uint256 cvxMaxSupply = 100_000_000e18;

  function setUp() public override {
    MainnetTest.setUp();
    fork();

    vm.startPrank(admin);
    mintRatio = new WarMintRatio();
    mintRatio.addTokenWithSupply(address(cvx), cvxMaxSupply);
    // TODO add aura
  }
}