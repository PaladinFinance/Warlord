// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./AuraLockerTest.sol";

contract Lock is AuraLockerTest {
  function testDefaultBehavior(uint256 amount) public {
    uint256 initialAmount = aura.balanceOf(address(minter));

    vm.assume(amount > 0 && amount < initialAmount);
    vm.prank(address(minter));
    locker.lock(amount);

    (, uint256 unlocked, uint256 locked, AuraLocker.LockedBalance[] memory lockData) =
      vlAura.lockedBalances(address(locker));

    assertEq(locked, amount, "locked balance is equivalent to initial aura amount");
    assertEq(aura.balanceOf(address(minter)), initialAmount - amount, "locked amount is deducted from aura balance");
    assertEq(unlocked, 0, "there should be no unlocked balance");
    assertEq(lockData[0].amount, amount, "amount should correspond to lockdata amount");
  }

  function testMultipleLocks(uint256[] memory amounts) public {
    vm.assume(amounts.length < 10);
    vm.startPrank(address(minter));

    uint256 totalLocked;
    for (uint256 i; i < amounts.length; ++i) {
      amounts[i] = amounts[i] % 1e30 + 1;
      deal(address(aura), address(minter), amounts[i]);
      locker.lock(amounts[i]);
      vm.warp(block.timestamp + 7 days);
      totalLocked += amounts[i];
    }
    vm.stopPrank();

    (,, uint256 locked, AuraLocker.LockedBalance[] memory lockData) = vlAura.lockedBalances(address(locker));

    assertEq(locked, totalLocked, "locked amount should correspond to total locked tokens");
    for (uint256 i; i < amounts.length; ++i) {
      assertEq(lockData[i].amount, amounts[i], "amounts should correspond to lockdata amount");
      if (i + 1 == lockData.length) continue;
      assertLt(
        lockData[i].unlockTime, lockData[i + 1].unlockTime, "The current lock should be smaller than the previous one"
      );
    }
  }
}
