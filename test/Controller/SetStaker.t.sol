// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./ControllerTest.sol";

contract SetStaker is ControllerTest {
  function testDefaultBehavior(address newStaker) public {
    vm.assume(newStaker != zero && newStaker != address(controller.staker()));

    address oldStaker = address(controller.staker());

    vm.expectEmit(true, false, false, true);
    emit SetStaker(oldStaker, newStaker);

    vm.prank(admin);
    controller.setStaker(newStaker);

    assertEq(address(controller.staker()), newStaker, "The new staker should be assinged correctly");
  }

  function testOnlyOnwer(address newStaker) public {
    vm.expectRevert("Ownable: caller is not the owner");
    controller.setStaker(newStaker);
  }

  function testZeroAddress() public {
    vm.expectRevert(Errors.ZeroAddress.selector);

    vm.prank(admin);
    controller.setStaker(zero);
  }

  function testAlreadySet() public {
    address oldStaker = address(controller.staker());

    vm.expectRevert(Errors.AlreadySet.selector);

    vm.prank(admin);
    controller.setStaker(oldStaker);
  }
}
