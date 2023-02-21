// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./CvxLockerTest.sol";

contract Lock is CvxLockerTest {
  function testDefaultBehavior(uint256 amount) public {
    uint256 initialAmount = cvx.balanceOf(address(minter));
    vm.assume(amount > 0 && amount < initialAmount);
    vm.prank(address(minter));
    locker.lock(amount);
    assertEq(vlCvx.lockedBalanceOf(address(locker)), amount);
    assertEq(cvx.balanceOf(address(minter)), initialAmount - amount);
  }
}
