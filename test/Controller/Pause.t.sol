// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./ControllerTest.sol";

contract Pause is ControllerTest {
  function testDefaultBehavior() public {
    assertFalse(controller.paused());
    vm.prank(admin);
    controller.pause();
    assertTrue(controller.paused());
  }

  function testOnlyOwner() public {
    vm.prank(alice);
    vm.expectRevert("Ownable: caller is not the owner");
    controller.pause();
  }
}
