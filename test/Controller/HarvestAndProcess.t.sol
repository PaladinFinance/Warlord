// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./ControllerTest.sol";

contract HarvestAndProcess is UnexposedControllerTest {
  address[] harvestables;

  function setUp() public override {
    UnexposedControllerTest.setUp();
    harvestables.push(address(cvxCrvFarmer));
    harvestables.push(address(auraBalFarmer));
    harvestables.push(address(cvxLocker));
    harvestables.push(address(auraLocker));
  }

  function testDefaultBehavior() public {
    for (uint256 i; i < harvestables.length; ++i) {
      vm.expectCall(harvestables[i], abi.encodeCall(IHarvestable(harvestables[i]).harvest, ()), 1);
      controller.harvestAndProcess(harvestables[i]);
    }
  }

  function testWhenNotPaused(address reward) public {
    vm.prank(admin);
    controller.pause();

    vm.expectRevert("Pausable: paused");
    controller.harvestAndProcess(reward);
  }
}
