// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./TokenTest.sol";

contract TransferOwnership is TokenTest {
  function testDefaultBehavior() public {
    vm.prank(admin);
    vm.expectEmit(true, true, false, true);
    emit NewPendingOwner(zero, alice);
    war.transferOwnership(alice);
    assertEq(war.owner(), admin);
    assertEq(war.pendingOwner(), alice);
  }

  function testOnlyAdminCanTransfer() public {
    vm.prank(alice);
    vm.expectRevert(
      "AccessControl: account 0x328809bc894f92807417d2dad6b7c998c1afdac6 is missing role 0x0000000000000000000000000000000000000000000000000000000000000000"
    );
    war.transferOwnership(alice);
  }

  function testOverridePendingOwner() public {
    vm.prank(admin);
    vm.expectEmit(true, true, false, true);
    emit NewPendingOwner(zero, alice);
    war.transferOwnership(alice);
    vm.prank(admin);
    vm.expectEmit(true, true, false, true);
    emit NewPendingOwner(alice, bob);
    war.transferOwnership(bob);
  }

  function testZeroAddressFails() public {
    vm.prank(admin);
    vm.expectRevert(Errors.ZeroAddress.selector);
    war.transferOwnership(zero);
  }

  function testOwnerAddressFails() public {
    vm.prank(admin);
    vm.expectRevert(Errors.CannotBeOwner.selector);
    war.transferOwnership(admin);
  }
}
