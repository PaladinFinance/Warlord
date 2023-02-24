// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./AuraLockerTest.sol";

contract ProcessUnlock is AuraLockerTest {
  function setUp() public override {
    AuraLockerTest.setUp();
    _mockMultipleLocks(1e25);
  }

  function testNoUnlockableBalance() public {
    (,, uint256 initiallyLocked,) = vlAura.lockedBalances(address(locker));

    locker.processUnlock();
    (, uint256 unlocked, uint256 locked,) = vlAura.lockedBalances(address(locker));
    assertEq(locked, initiallyLocked, "after processUnlock the lockedBalance shouldn't have changed");
    assertEq(unlocked, 0, "after processUnlock there shouldn't be any unlockable balance");
  }

  function testFullRelock() public {
    (, uint256 initiallyUnlocked, uint256 initiallyLocked,) = vlAura.lockedBalances(address(locker));
    assertEq(initiallyUnlocked, 0, "before warping no aura should be unlockable");
    vm.warp(block.timestamp + 1000 days);

    (, uint256 unlocked, uint256 locked,) = vlAura.lockedBalances(address(locker));
    assertEq(locked, 0, "after warping all the locked balance should be zero");
    assertEq(unlocked, initiallyLocked, "after warping all the unlocked balance should be unlockable");

    locker.processUnlock();
    (, unlocked, locked,) = vlAura.lockedBalances(address(locker));
    assertEq(locked, initiallyLocked, "after processUnlock the lockedBalance should be back");
    assertEq(unlocked, 0, "after processUnlock there shouldn't be any unlockable balance");
  }

  function testUnlockAndRelock(uint256 withdrawDesired, uint256 daysPassed) public {
    vm.assume(daysPassed < 120 days);

    // Queue rewards withdrawal
    redeemModule.setQueue(withdrawDesired);
    assertEq(redeemModule.queuedForWithdrawal(address(aura)), withdrawDesired, "mock should assign value correctly");

    // Move in a random point in time that may have expired and not expired locks
    vm.warp(block.timestamp + daysPassed);

    (, uint256 initiallyUnlocked, uint256 initiallyLocked,) = vlAura.lockedBalances(address(locker));
    locker.processUnlock();

    (, uint256 unlocked, uint256 locked,) = vlAura.lockedBalances(address(locker));
    assertEq(unlocked, 0, "there should be no more unlocked aura");

    uint256 newLocks = locked - initiallyLocked;
    uint256 amountWithdrawn = withdrawDesired - redeemModule.queuedForWithdrawal(address(aura));
    assertEq(newLocks + amountWithdrawn, initiallyUnlocked, "the unlocked funds have to go into relock or redeemModule");
  }
}
