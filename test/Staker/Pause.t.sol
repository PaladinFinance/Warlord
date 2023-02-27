// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./StakerTest.sol";

contract Pause is StakerTest {
  function testDefaultBehavior() public {
    assertEq(staker.paused(), false);
    vm.prank(admin);
    staker.pause();
    assertEq(staker.paused(), true);
  }

  function testOnlyOwner() public {
    vm.prank(alice);
    vm.expectRevert("Ownable: caller is not the owner");
    staker.pause();
  }
}