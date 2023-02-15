// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./TokenTest.sol";

contract Constructor is TokenTest {
  function testDefaultBehavior() public {
    assertEq(war.owner(), admin);
    assertEq(war.pendingOwner(), zero);
    assertTrue(war.hasRole(0x0, admin));
    assertEq(war.getRoleAdmin(0x0), keccak256("NO_ROLE"));
  }
}
