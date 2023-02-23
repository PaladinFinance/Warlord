// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./AuraLockerTest.sol";

contract Constructor is AuraLockerTest {
  function testDefaultBehavior() public {
    assertEq(registry.delegation(address(locker), "aurafinance.eth"), delegatee);
  }
}
