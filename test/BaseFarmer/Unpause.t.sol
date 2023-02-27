// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./BaseFarmerTest.sol";

contract Unpause is BaseFarmerTest {
  function setUp() public override {
    BaseFarmerTest.setUp();
    vm.prank(admin);
    dummyFarmer.pause();
  }

  function testDefaultBehavior() public {
    assertEq(dummyFarmer.paused(), true);
    vm.prank(admin);
    dummyFarmer.unpause();
    assertEq(dummyFarmer.paused(), false);
  }

  function testOnlyOwner() public {
    vm.prank(alice);
    vm.expectRevert("Ownable: caller is not the owner");
    dummyFarmer.unpause();
  }
}
