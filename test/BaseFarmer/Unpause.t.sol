// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./BaseFarmerTest.sol";

contract Unpause is BaseFarmerTest {
  function setUp() public override {
    BaseFarmerTest.setUp();
    vm.prank(admin);
    warMockFarmer.pause();
  }

  function testDefaultBehavior() public {
    assertEq(warMockFarmer.paused(), true);
    vm.prank(admin);
    warMockFarmer.unpause();
    assertEq(warMockFarmer.paused(), false);
  }

  function testOnlyOwner() public {
    vm.prank(alice);
    vm.expectRevert("Ownable: caller is not the owner");
    warMockFarmer.unpause();
  }
}
