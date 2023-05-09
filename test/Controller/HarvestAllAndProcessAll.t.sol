// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./ControllerTest.sol";

contract HarvestAllAndProcessAll is UnexposedControllerTest {
  function testDefaultBehavior() public {
    for (uint256 i; i < 2; ++i) {
      // TODO use exposed controller
      address locker = controller.lockers(i);
      vm.expectCall(locker, abi.encodeCall(IHarvestable(locker).harvest, ()), 1);
    }

    for (uint256 i; i < 2; ++i) {
      // TODO use exposed controller
      address farmer = controller.farmers(i);
      vm.expectCall(farmer, abi.encodeCall(IHarvestable(farmer).harvest, ()), 1);
    }
    controller.harvestAllAndProcessAll();
  }

  function testWhenNotPaused() public {
    vm.prank(admin);
    controller.pause();

    vm.expectRevert("Pausable: paused");
    controller.harvestAllAndProcessAll();
  }
}
