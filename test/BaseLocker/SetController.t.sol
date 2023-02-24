// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./BaseLockerTest.sol";

contract SetController is BaseLockerTest {
  function testDefaultBehavior(address newController) public {
    vm.assume(newController != zero && newController != controller);
    vm.prank(admin);

    vm.expectEmit(false, false, false, true);
    emit SetController(newController);

    dummyLocker.setController(newController);

    assertEq(dummyLocker.controller(), newController, "newController should be the new controller");
  }

  function testRevertWithZeroAddress() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    vm.prank(admin);
    dummyLocker.setController(zero);
  }

  function testOnlyOwner() public {
    vm.expectRevert("Ownable: caller is not the owner");
    dummyLocker.setController(alice);
  }

  function testSameValue() public {
    vm.expectRevert(Errors.AlreadySet.selector);
    vm.prank(admin);
    dummyLocker.setController(controller);
  }
}
