// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarTokenTest.sol";

contract Constructor is WarTokenTest {
  function testDefaultBehavior() public {
    assertEq(war.owner(), admin);
    assertEq(war.pendingOwner(), zero);
    assertTrue(war.hasRole(0x0, admin));
    assertEq(war.getRoleAdmin(0x0), keccak256("NO_ROLE"));
  }
}
