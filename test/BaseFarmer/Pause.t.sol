// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./BaseFarmerTest.sol";

contract Pause is BaseFarmerTest {
  function testDefaultBehavior() public {
    assertEq(dummyFarmer.paused(), false);
    vm.prank(admin);
    dummyFarmer.pause();
    assertEq(dummyFarmer.paused(), true);
  }

  function testOnlyOwner() public {
    vm.prank(alice);
    vm.expectRevert("Ownable: caller is not the owner");
    dummyFarmer.pause();
  }
}
