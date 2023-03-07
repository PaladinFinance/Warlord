// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./BaseFarmerTest.sol";

contract Constructor is BaseFarmerTest {
  function testDefaultBehavior() public {
    assertEq(dummyFarmer.controller(), controller);
    assertEq(dummyFarmer.warStaker(), address(warStaker));
  }

  function testZeroControllerReverts(address staker) public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    new WarDummyFarmer(zero, staker);
  }

  function testZeroWarStakerReverts(address controller) public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    new WarDummyFarmer(controller, zero);
  }

  function testZeroAddresses() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    new WarDummyFarmer(zero, zero);
  }
}
