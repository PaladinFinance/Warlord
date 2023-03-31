// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./StakerTest.sol";

contract Unpause is StakerTest {
  function setUp() public override {
    StakerTest.setUp();
    vm.prank(admin);
    staker.pause();
  }

  function testDefaultBehavior() public {
    assertTrue(staker.paused());
    vm.prank(admin);
    staker.unpause();
    assertFalse(staker.paused());
  }

  function testOnlyOwner() public {
    vm.expectRevert("Ownable: caller is not the owner");
    staker.unpause();
  }
}
