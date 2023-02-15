// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarStakerTest.sol";

contract Unstake is WarStakerTest {
  function setUp() public override {
    WarStakerTest.setUp();
    // staker.stake(50e18, alice);
  }

  function testDeafultBehavior() public {}
}
