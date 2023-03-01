// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./StakerTest.sol";

contract QueueRewards is StakerTest {
  function testDefaultBehavior() public {}
  function testZeroReceiver() public {
    // staker.claimRewards();
  }
  function testNonReentrant() public {}
  function testWhenNotPaused() public {}
}
