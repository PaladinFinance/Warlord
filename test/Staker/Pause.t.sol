// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./StakerTest.sol";

contract Pause is StakerTest {
  function testDefaultBehavior() public {
    assertFalse(staker.paused());
    vm.prank(admin);
    staker.pause();
    assertTrue(staker.paused());
  }

  function testOnlyOwner() public {
    vm.expectRevert("Ownable: caller is not the owner");
    staker.pause();
  }
}
