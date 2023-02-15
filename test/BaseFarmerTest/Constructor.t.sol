// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./BaseFarmerTest.sol";

contract Constructor is BaseFarmerTest {
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
