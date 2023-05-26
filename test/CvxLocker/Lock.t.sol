// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./CvxLockerTest.sol";

contract Lock is CvxLockerTest {
  function testDefaultBehavior(uint256 amount) public {
    uint256 initialAmount = cvx.balanceOf(address(minter));

    vm.assume(amount > 0 && amount < initialAmount);
    vm.prank(address(minter));
    locker.lock(amount);

    (, uint256 unlocked, uint256 locked, CvxLockerV2.LockedBalance[] memory lockData) =
      vlCvx.lockedBalances(address(locker));

    assertEq(vlCvx.lockedBalanceOf(address(locker)), amount, "locked balance is equivalent to initial cvx amount");
    assertEq(locked, amount, "locked balance is equivalent to initial cvx amount");
    assertEq(cvx.balanceOf(address(minter)), initialAmount - amount, "locked amount is deducted from cvx balance");
    assertEq(unlocked, 0, "there should be no unlocked balance");
    assertEq(lockData[0].amount, amount, "amount should correspond to lockdata amount");
  }

  function testMultipleLocks(uint256[] memory amounts) public {
    vm.assume(amounts.length < 10);
    vm.startPrank(address(minter));

    uint256 totalLocked;
    for (uint256 i; i < amounts.length; ++i) {
      amounts[i] = amounts[i] % 1e30 + 1;
      deal(address(cvx), address(minter), amounts[i]);
      locker.lock(amounts[i]);
      vm.warp(block.timestamp + 7 days);
      totalLocked += amounts[i];
    }
    vm.stopPrank();

    (,, uint256 locked, CvxLockerV2.LockedBalance[] memory lockData) = vlCvx.lockedBalances(address(locker));

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
