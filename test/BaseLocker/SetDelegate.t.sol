// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./BaseLockerTest.sol";

contract SetDelegate is BaseLockerTest {
  function testDefaultBehavior(address _delegatee) public {
    vm.prank(admin);

    vm.expectEmit(false, false, false, true);
    emit SetDelegate(_delegatee);

    dummyLocker.setDelegate(_delegatee);

    assertEq(dummyLocker.delegatee(), _delegatee, "delegation value in contract has to be changed correctly");
  }

  function testOnlyOwner(address _delegatee) public {
    vm.expectRevert("Ownable: caller is not the owner");
    dummyLocker.setDelegate(_delegatee);
  }
}
