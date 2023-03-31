// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./RedeemerTest.sol";

contract Unpause is RedeemerTest {
  function setUp() public override {
    RedeemerTest.setUp();
    vm.prank(admin);
    redeemer.pause();
  }

  function testDefaultBehavior() public {
    assertTrue(redeemer.paused());
    vm.prank(admin);
    redeemer.unpause();
    assertFalse(redeemer.paused());
  }

  function testOnlyOwner() public {
    vm.expectRevert("Ownable: caller is not the owner");
    redeemer.unpause();
  }
}
