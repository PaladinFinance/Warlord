// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./ZapTest.sol";

contract Unpause is ZapTest {
  function setUp() public override {
    ZapTest.setUp();
    vm.prank(admin);
    zap.pause();
  }

  function testDefaultBehavior() public {
    assertTrue(zap.paused(), "the contract should be paused at the beginning");
    vm.prank(admin);
    zap.unpause();
    assertFalse(zap.paused(), "the contract should be unpaused after the call");
  }

  function testOnlyOwner() public {
    vm.expectRevert("Ownable: caller is not the owner");
    zap.unpause();
  }
}
