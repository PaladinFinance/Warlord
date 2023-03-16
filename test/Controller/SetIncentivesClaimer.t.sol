// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./ControllerTest.sol";

contract SetIncentivesClaimer is ControllerTest {
  function testDefaultBehavior(address newIncentivesClaimer) public {
    vm.assume(newIncentivesClaimer != zero && newIncentivesClaimer != controller.incentivesClaimer());

    address oldIncentivesClaimer = controller.incentivesClaimer();

    vm.expectEmit(true, false, false, true);
    emit SetIncentivesClaimer(oldIncentivesClaimer, newIncentivesClaimer);

    vm.prank(admin);
    controller.setIncentivesClaimer(newIncentivesClaimer);

    assertEq(
      controller.incentivesClaimer(), newIncentivesClaimer, "The new incentives claimer should be assinged correctly"
    );
  }

  function testOnlyOnwer(address newIncentivesClaimer) public {
    vm.expectRevert("Ownable: caller is not the owner");
    controller.setIncentivesClaimer(newIncentivesClaimer);
  }

  function testZeroAddress() public {
    vm.expectRevert(Errors.ZeroAddress.selector);

    vm.prank(admin);
    controller.setIncentivesClaimer(zero);
  }

  function testAlreadySet() public {
    address oldIncentivesClaimer = controller.incentivesClaimer();

    vm.expectRevert(Errors.AlreadySet.selector);

    vm.prank(admin);
    controller.setIncentivesClaimer(oldIncentivesClaimer);
  }
}
