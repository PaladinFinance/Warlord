// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarTokenTest.sol";

contract Constructor is WarTokenTest {
  function testDeployedWithCorrectOwners() public {
    assertEq(war.owner(), admin);
    assertEq(war.pendingOwner(), zero);
  }

  // TODO check non zero address
}
