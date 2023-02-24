// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./AuraLockerTest.sol";

contract Token is AuraLockerTest {
  function testDefaultBehavior() public {
    assertEq(locker.token(), address(aura));
  }
}
