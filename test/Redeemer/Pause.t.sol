// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./RedeemerTest.sol";

contract Pause is RedeemerTest {
  function testDefaultBehavior() public {
    assertFalse(redeemer.paused());
    vm.prank(admin);
    redeemer.pause();
    assertTrue(redeemer.paused());
  }

  function testOnlyOwner() public {
    vm.expectRevert("Ownable: caller is not the owner");
    redeemer.pause();
  }
}
