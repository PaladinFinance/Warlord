// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./ControllerTest.sol";

contract SetFeeRatio is ControllerTest {
  function testDefaultBehavior(uint256 newFeeRatio) public {
    vm.assume(newFeeRatio <= 1000 && newFeeRatio != controller.feeRatio());

    uint256 oldFeeRatio = controller.feeRatio();

    vm.expectEmit(true, false, false, true);
    emit SetFeeRatio(oldFeeRatio, newFeeRatio);

    vm.prank(admin);
    controller.setFeeRatio(newFeeRatio);

    assertEqDecimal(controller.feeRatio(), newFeeRatio, 2, "The new fee ratio should be assinged correctly");
  }

  function testOnlyOnwer(uint256 newFeeRatio) public {
    vm.expectRevert("Ownable: caller is not the owner");
    controller.setFeeRatio(newFeeRatio);
  }

  function testInvalidFeeRatio(uint256 newFeeRatio) public {
    vm.assume(newFeeRatio > 1000);

    vm.expectRevert(Errors.InvalidFeeRatio.selector);

    vm.prank(admin);
    controller.setFeeRatio(newFeeRatio);
  }

  function testAlreadySet() public {
    uint256 oldFeeRatio = controller.feeRatio();

    vm.expectRevert(Errors.AlreadySet.selector);

    vm.prank(admin);
    controller.setFeeRatio(oldFeeRatio);
  }
}
