// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./ZapTest.sol";

contract Unpause is ZapTest {
  function setUp() public override {
    ZapTest.setUp();
    vm.prank(admin);
    staker.pause();
  }

  function testDefaultBehavior() public {
    assertTrue(staker.paused(), "the contract should be paused at the beginning");
    vm.prank(admin);
    staker.unpause();
    assertFalse(staker.paused(), "the contract should be unpaused after the call");
  }

  function testOnlyOwner() public {
    vm.expectRevert("Ownable: caller is not the owner");
    staker.unpause();
  }
}
