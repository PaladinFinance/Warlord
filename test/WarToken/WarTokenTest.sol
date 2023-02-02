// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "../../src/WarToken.sol";
import "../BaseTest.sol";

contract WarTokenTest is BaseTest {
  event NewPendingOwner(address indexed previousPendingOwner, address indexed newPendingOwner);

  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
  bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

  address minter = makeAddr("minter");
  address burner = makeAddr("burner");

  WarToken war;

  function setUp() public virtual {
    war = new WarToken(admin);
    vm.startPrank(admin);
    war.grantRole(MINTER_ROLE, minter);
    war.grantRole(BURNER_ROLE, burner);
    vm.stopPrank();
  }
}
