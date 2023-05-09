// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./ControllerTest.sol";

contract HarvestAll is UnexposedControllerTest {
  address[] harvestables;

  function setUp() public override {
    UnexposedControllerTest.setUp();
    harvestables.push(address(cvxCrvFarmer));
    harvestables.push(address(auraBalFarmer));
    harvestables.push(address(cvxLocker));
    harvestables.push(address(auraLocker));
  }

  function testDefaultBehavior() public {
    vm.expectCall(address(auraBalStaker), abi.encodeWithSelector(hex"7050ccd9", address(auraBalFarmer), true), 1);
    vm.expectCall(
      address(convexCvxCrvStaker), abi.encodeWithSelector(hex"6b091695", address(cvxCrvFarmer), address(controller)), 1
    );
    vm.expectCall(address(vlCvx), abi.encodeWithSelector(hex"7050ccd9", address(cvxLocker), false), 1);
    vm.expectCall(address(vlAura), abi.encodeWithSelector(hex"7050ccd9", address(auraLocker), false), 1);

    controller.harvestAll();
  }

  function testWhenNotPaused() public {
    vm.prank(admin);
    controller.pause();

    vm.expectRevert("Pausable: paused");
    controller.harvestAll();
  }
}
