// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./ControllerTest.sol";

contract SetFeeReceiver is ControllerTest {
  function testDefaultBehavior(address newFeeReceiver) public {
    vm.assume(newFeeReceiver != zero && newFeeReceiver != controller.feeReceiver());

    address oldFeeReceiver = controller.feeReceiver();

    vm.expectEmit(true, false, false, true);
    emit SetFeeReceiver(oldFeeReceiver, newFeeReceiver);

    vm.prank(admin);
    controller.setFeeReceiver(newFeeReceiver);

    assertEq(controller.feeReceiver(), newFeeReceiver, "The new fee receiver should be assinged correctly");
  }

  function testOnlyOnwer(address newFeeReceiver) public {
    vm.expectRevert("Ownable: caller is not the owner");
    controller.setFeeReceiver(newFeeReceiver);
  }

  function testZeroAddress() public {
    vm.expectRevert(Errors.ZeroAddress.selector);

    vm.prank(admin);
    controller.setFeeReceiver(zero);
  }

  function testAlreadySet() public {
    // TODO should this be initialised elsewhere?
    vm.prank(admin);
    controller.setFeeReceiver(address(1));

    address oldFeeReceiver = controller.feeReceiver();

    vm.expectRevert(Errors.AlreadySet.selector);

    vm.prank(admin);
    controller.setFeeReceiver(oldFeeReceiver);
  }
}
