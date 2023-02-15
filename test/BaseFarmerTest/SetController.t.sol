// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./BaseFarmerTest.sol";

contract SetController is BaseFarmerTest {
  function testDefaultBehavior(address newController) public {
    vm.assume(newController != zero && newController != controller);
    vm.prank(admin);
    warMockFarmer.setController(newController);
    assertEq(warMockFarmer.controller(), newController);
  }

  function testRevertWithZeroAddress() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    vm.prank(admin);
    warMockFarmer.setController(zero);
  }

  function testOnlyOwner() public {
    vm.expectRevert("Ownable: caller is not the owner");
    warMockFarmer.setController(alice);
  }

  function testSameValue() public {
    vm.expectRevert(Errors.AlreadySet.selector);
    vm.prank(admin);
    warMockFarmer.setController(controller);
  }
}
