// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./StakerTest.sol";

contract Unstake is StakerTest {
  function setUp() public override {
    StakerTest.setUp();
    // staker.stake(50e18, alice);
  }

  function testDeafultBehavior() public {}
}
