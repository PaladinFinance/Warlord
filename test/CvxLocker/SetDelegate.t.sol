// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./CvxLockerTest.sol";

contract SetDelegate is CvxLockerTest {
  function testDefaultBehavior(address _delegatee) public {
    console.log(locker.owner());
    console.log(admin);
    vm.assume(_delegatee != locker.delegatee() && _delegatee != zero);
    vm.startPrank(admin);
    locker.setDelegate(_delegatee);
    vm.stopPrank();
    assertEq(locker.delegatee(), _delegatee);
    assertEq(registry.delegation(address(locker), "cvx.eth"), _delegatee);
  }
}
