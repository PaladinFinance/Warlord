// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarCvxCrvStakerTest.sol";

contract SetController is WarCvxCrvStakerTest {
  function testDefaultBehavior(address newController) public {
    vm.assume(newController != zero && newController != controller);
    vm.prank(admin);
    warCvxCrvStaker.setController(newController);
    assertEq(warCvxCrvStaker.controller(), newController);
  }

  function testRevertWithZeroAddress() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    vm.prank(admin);
    warCvxCrvStaker.setController(zero);
  }

  function testOnlyOwner() public {
    vm.expectRevert("Ownable: caller is not the owner");
    warCvxCrvStaker.setController(alice);
  }

  function testSameValue() public {
    vm.expectRevert(Errors.AlreadySet.selector);
    vm.prank(admin);
    warCvxCrvStaker.setController(controller);
  }
}
