// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "../MainnetTest.sol";
import "../../src/MintRatio.sol";

contract MintRatioTest is MainnetTest {
  IMintRatio mintRatio;

  function setUp() public override {
    MainnetTest.setUp();
    fork();

    mintRatio = new MintRatio();
  }
}
