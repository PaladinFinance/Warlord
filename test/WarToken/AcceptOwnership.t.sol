// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarTokenTest.sol";

contract AcceptOwnership is WarTokenTest {
  function setUp() public override {
    WarTokenTest.setUp();
    vm.prank(admin);
    war.transferOwnership(alice);
  }

  function testAcceptWorks() public {
    assertEq(war.owner(), admin);
    assertEq(war.pendingOwner(), alice);
    vm.prank(alice);
    vm.expectEmit(true, true, false, true);
    emit NewPendingOwner(alice, address(0));
    war.acceptOwnership();
    assertEq(war.owner(), alice);
    assertEq(war.pendingOwner(), address(0));
  }

  function testOnlyPendingOwnerCanAccept() public {
    vm.prank(bob);
    vm.expectRevert(WarToken.CallerNotPendingOwner.selector);
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
