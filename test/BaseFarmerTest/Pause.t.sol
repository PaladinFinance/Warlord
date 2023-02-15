// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarBaseFarmerTest.sol";

contract Pause is WarBaseFarmerTest {
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
