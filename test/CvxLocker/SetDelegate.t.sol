// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./CvxLockerTest.sol";

contract SetDelegate is CvxLockerTest {
  function testDefaultBehavior(address _delegatee) public {
    vm.assume(_delegatee != locker.delegatee() && _delegatee != zero);
    vm.prank(admin);
    locker.setDelegate(_delegatee);
    assertEq(locker.delegatee(), _delegatee, "delegation value in contract has to be changed correctly");
    assertEq(
      registry.delegation(address(locker), "cvx.eth"), _delegatee, "the delegation registry has to change accordingly"
    );
  }
}
