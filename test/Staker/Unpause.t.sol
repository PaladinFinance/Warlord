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
    assertEq(staker.paused(), true);
    vm.prank(admin);
    staker.unpause();
    assertEq(staker.paused(), false);
  }

  function testOnlyOwner() public {
    vm.prank(alice);
    vm.expectRevert("Ownable: caller is not the owner");
    staker.unpause();
  }
}
