// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarCvxLockerTest.sol";

contract Lock is WarCvxLockerTest {
  function testDefaultBehavior(uint256 amount) public {
    uint256 initialAmount = cvx.balanceOf(address(minter));
    vm.assume(amount > 0 && amount < initialAmount);
    vm.prank(address(minter));
    locker.lock(amount);
    assertEq(vlCvx.lockedBalanceOf(address(locker)), amount);
    assertEq(cvx.balanceOf(address(minter)), initialAmount - amount);
  }

  function testZeroAmount() public {
    vm.expectRevert(Errors.ZeroValue.selector);
    vm.prank(address(minter));
    locker.lock(0);
  }

  function testOnlyWarMinter() public {
    vm.expectRevert(Errors.CallerNotAllowed.selector);
    locker.lock(423_759_020);
  }
}
