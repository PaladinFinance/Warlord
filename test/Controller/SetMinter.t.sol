// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./ControllerTest.sol";

contract SetMinter is ControllerTest {
  function testDefaultBehavior(address newMinter) public {
    vm.assume(newMinter != zero && newMinter != address(controller.minter()));

    address oldMinter = address(controller.minter());

    vm.expectEmit(true, false, false, true);
    emit SetMinter(oldMinter, newMinter);

    vm.prank(admin);
    controller.setMinter(newMinter);

    assertEq(address(controller.minter()), newMinter, "The new fee receiver should be assinged correctly");
  }

  function testOnlyOnwer(address newMinter) public {
    vm.expectRevert("Ownable: caller is not the owner");
    controller.setMinter(newMinter);
  }

  function testZeroAddress() public {
    vm.expectRevert(Errors.ZeroAddress.selector);

    vm.prank(admin);
    controller.setMinter(zero);
  }

  function testAlreadySet() public {
    address oldMinter = address(controller.minter());

    vm.expectRevert(Errors.AlreadySet.selector);

    vm.prank(admin);
    controller.setMinter(oldMinter);
  }
}
