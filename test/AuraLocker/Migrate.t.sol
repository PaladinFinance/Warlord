// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./AuraLockerTest.sol";

contract Migrate is AuraLockerTest {
  address receiver = makeAddr("receiver");

  function setUp() public override {
    AuraLockerTest.setUp();

    _mockMultipleLocks(1e25);

    vm.startPrank(admin);
    locker.pause();
    locker.shutdown();
    vm.stopPrank();
  }

  function testDefaultBehavior() public {
    // TODO #19
    vm.warp(block.timestamp + 1000 days);
    uint256 auraBalRewards = _getRewards();
    (,, uint256 initialLockedBalance,) = vlAura.lockedBalances(address(locker));

    vm.prank(admin);
    locker.migrate(receiver);

    // check cvx balance migration to receiver
    (,, uint256 locked,) = vlAura.lockedBalances(address(locker));
    assertEq(locked, 0, "no more vlAura should be locked");
    assertEq(cvx.balanceOf(receiver), initialLockedBalance, "balance of receiver should be equal to initial vlAura");

    // all rewards were claimed
    _assertNoPendingRewards();

    assertEq(auraBalRewards, auraBal.balanceOf(controller), "check accrued rewards to controller for cvxCrv");
  }
}
