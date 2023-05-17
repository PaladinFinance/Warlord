// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./ControllerTest.sol";

contract SetHarvestableToken is UnexposedControllerTest {
  function testDefaultBehavior(address target, bool enable) public {
    vm.assume(target != zero);

    assertFalse(controller.harvestable(target), "Target harvestability should be false by default");

    vm.expectEmit();
    emit SetHarvestable(target, enable);
    vm.prank(admin);
    controller.setHarvestableToken(target, enable);

    assertEq(controller.harvestable(target), enable, "Target harvestability should be set accordingly");
  }

  function testZeroAddress(bool enable) public {
    vm.prank(admin);
    vm.expectRevert(Errors.ZeroAddress.selector);
    controller.setHarvestableToken(zero, enable);
  }

  function testOnlyOwner(address target, bool enable) public {
    vm.expectRevert("Ownable: caller is not the owner");
    controller.setHarvestableToken(target, enable);
  }
}
