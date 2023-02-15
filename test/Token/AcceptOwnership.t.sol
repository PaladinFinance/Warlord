// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./TokenTest.sol";

contract AcceptOwnership is TokenTest {
  function setUp() public override {
    TokenTest.setUp();
    vm.prank(admin);
    war.transferOwnership(alice);
  }

  function testDefaultBehavior() public {
    assertEq(war.owner(), admin);
    assertEq(war.pendingOwner(), alice);
    vm.prank(alice);
    vm.expectEmit(true, true, false, true);
    emit NewPendingOwner(alice, zero);
    war.acceptOwnership();
    assertEq(war.owner(), alice);
    assertEq(war.pendingOwner(), zero);
  }

  function testOnlyPendingOwnerCanAccept() public {
    vm.prank(bob);
    vm.expectRevert(Errors.CallerNotPendingOwner.selector);
    war.acceptOwnership();
  }

  function testNewOwnerCanCallGatedFunctions() public {
    vm.startPrank(alice);
    war.acceptOwnership();
    war.renounceRole(0x00, alice);
  }

  function testOldOwnerCantCallGatedFunctions() public {
    vm.prank(alice);
    war.acceptOwnership();
    vm.prank(admin);
    vm.expectRevert(
      "AccessControl: account 0xaa10a84ce7d9ae517a52c6d5ca153b369af99ecf is missing role 0x0000000000000000000000000000000000000000000000000000000000000000"
    );
    war.transferOwnership(bob);
  }
}
