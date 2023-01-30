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
		war.transferOwnership(alice);
		assertEq(war.owner(), admin);
		assertEq(war.pendingOwner(), alice);
		// TODO check for emit
	}

	function testZeroAddressFails() public {
		vm.prank(admin);
		vm.expectRevert(); //TODO add precise error
		war.transferOwnership(address(0));
	}

	function testOwnerAddressFails() public {
		vm.prank(admin);
		vm.expectRevert(); //TODO add precise error
		war.transferOwnership(admin);
	}
}
