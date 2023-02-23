// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./AuraLockerTest.sol";

contract Lock is AuraLockerTest {
  function testDefaultBehavior(uint256 amount) public {
    uint256 initialAmount = aura.balanceOf(address(minter));

    vm.assume(amount > 0 && amount < initialAmount);
    vm.prank(address(minter));
    locker.lock(amount);

    (, uint256 unlocked, uint256 locked,) = vlAura.lockedBalances(address(locker));
    assertEq(locked, amount, "locked balance is equivalent to initial aura amount");
    assertEq(aura.balanceOf(address(minter)), initialAmount - amount, "locked amount is deducted from aura balance");
    assertEq(unlocked, 0, "there should be no unlocked balance");
  }

  // TODO more advanced testing with lockData (check in lockedBalances)
}
