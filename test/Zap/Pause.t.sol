// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./ZapTest.sol";

contract Pause is ZapTest {
  function testDefaultBehavior() public {
    assertFalse(zap.paused(), "the contract shouldn't be paused at the start");
    vm.prank(admin);
    zap.pause();
    assertTrue(zap.paused(), "the contract should be paused after the call");
  }

  function testOnlyOwner() public {
    vm.expectRevert("Ownable: caller is not the owner");
    zap.pause();
  }
}
