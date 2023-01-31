// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarTokenTest.sol";

contract TransferOwnership is WarTokenTest {
  function testOnlyAdminCanTransfer() public {
    vm.prank(alice);
    vm.expectRevert(
      "AccessControl: account 0x328809bc894f92807417d2dad6b7c998c1afdac6 is missing role 0x0000000000000000000000000000000000000000000000000000000000000000"
    );
    war.transferOwnership(alice);
  }

  function testFirstStepChangesPendingOwner() public {
    vm.prank(admin);
    vm.expectEmit(true, true, false, true);
    emit NewPendingOwner(address(0), alice);
    war.transferOwnership(alice);
    assertEq(war.owner(), admin);
    assertEq(war.pendingOwner(), alice);
  }

  function testOverridePendingOwner() public {
    vm.prank(admin);
    vm.expectEmit(true, true, false, true);
    emit NewPendingOwner(address(0), alice);
    war.transferOwnership(alice);
    vm.prank(admin);
    vm.expectEmit(true, true, false, true);
    emit NewPendingOwner(alice, bob);
    war.transferOwnership(bob);
  }

  function testZeroAddressFails() public {
    vm.prank(admin);
    vm.expectRevert(WarToken.ZeroAddress.selector);
    war.transferOwnership(address(0));
  }

  function testOwnerAddressFails() public {
    vm.prank(admin);
    vm.expectRevert(WarToken.CannotBeOwner.selector);
    war.transferOwnership(admin);
  }
}
