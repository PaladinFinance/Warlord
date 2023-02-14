// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarBaseFarmerTest.sol";

contract Constructor is WarBaseFarmerTest {
  function testDefaultBehavior() public {
    assertEq(warMockFarmer.controller(), controller);
    assertEq(warMockFarmer.warStaker(), address(warStaker));
  }

  function testZeroControllerReverts() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    new WarMockFarmer(zero, alice);
  }

  function testZeroWarStakerReverts() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    new WarMockFarmer(bob, zero);
  }

  function testZeroAddresses() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    new WarMockFarmer(zero, zero);
  }
}
