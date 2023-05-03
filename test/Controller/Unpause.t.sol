// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./ControllerTest.sol";

contract Unpause is ControllerTest {
  function setUp() public override {
    ControllerTest.setUp();
    vm.prank(admin);
    controller.pause();
  }

  function testDefaultBehavior() public {
    assertTrue(controller.paused());
    vm.prank(admin);
    controller.unpause();
    assertFalse(controller.paused());
  }

  function testOnlyOwner() public {
    vm.prank(alice);
    vm.expectRevert("Ownable: caller is not the owner");
    controller.unpause();
  }
}
