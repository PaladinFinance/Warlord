// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "../../src/WarToken.sol";
import "../BaseTest.sol";

contract WarTokenTest is BaseTest {
  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

  address admin = makeAddr("admin");
  address minter = makeAddr("minter");

  WarToken war;

  function setUp() public virtual {
    war = new WarToken(admin);
    vm.prank(admin);
    war.grantRole(MINTER_ROLE, minter);
  }
}
