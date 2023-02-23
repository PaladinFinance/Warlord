// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./AuraLockerTest.sol";

contract Harvest is AuraLockerTest {
  function setUp() public override {
    AuraLockerTest.setUp();
    _assertNoPendingRewards();
    _mockMultipleLocks(1e25);
  }

  function testDefaultBehavior(uint256 time) public {
    vm.assume(time < 10_000 days);

    vm.warp(block.timestamp + time);

    uint256 auraBalRewards = _getRewards();
    locker.harvest();

    // check accrued rewards harvest to controller
    assertEq(auraBalRewards, auraBal.balanceOf(controller), "expecting pending rewards for auraBal");

    // check there's no rewards lefts after harvesting
    _assertNoPendingRewards();
  }
}
