// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./ControllerTest.sol";

contract SetSwapper is ControllerTest {
  function testDefaultBehavior(address newSwapper) public {
    vm.assume(newSwapper != zero && newSwapper != controller.swapper());

    address oldSwapper = controller.swapper();

    vm.expectEmit(true, false, false, true);
    emit SetSwapper(oldSwapper, newSwapper);

    vm.prank(admin);
    controller.setSwapper(newSwapper);

    assertEq(controller.swapper(), newSwapper, "The new swapper should be assinged correctly");
  }

  function testOnlyOnwer(address newSwapper) public {
    vm.expectRevert("Ownable: caller is not the owner");
    controller.setSwapper(newSwapper);
  }

  function testZeroAddress() public {
    vm.expectRevert(Errors.ZeroAddress.selector);

    vm.prank(admin);
    controller.setSwapper(zero);
  }

  function testAlreadySet() public {
    address oldSwapper = controller.swapper();

    vm.expectRevert(Errors.AlreadySet.selector);

    vm.prank(admin);
    controller.setSwapper(oldSwapper);
  }
}
