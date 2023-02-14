// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarBaseFarmerTest.sol";

contract Unpause is WarBaseFarmerTest {
  function setUp() public override {
    WarBaseFarmerTest.setUp();
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
