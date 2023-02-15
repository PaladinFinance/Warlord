// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./BaseFarmerTest.sol";

contract Pause is BaseFarmerTest {
  function testDefaultBehavior() public {
    assertEq(warMockFarmer.paused(), false);
    vm.prank(admin);
    warMockFarmer.pause();
    assertEq(warMockFarmer.paused(), true);
  }

  function testOnlyOwner() public {
    vm.prank(alice);
    vm.expectRevert("Ownable: caller is not the owner");
    warMockFarmer.pause();
  }
}
