// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarTokenTest.sol";

contract Mint is WarTokenTest {
  function testDefaultBehavior(uint256 amount) public {
    vm.prank(admin);
    war.grantRole(MINTER_ROLE, alice);
    assertEq(war.balanceOf(bob), 0);
    assertEq(war.totalSupply(), 0);
    vm.prank(alice);
    war.mint(bob, amount);
    assertEq(war.balanceOf(bob), amount);
    assertEq(war.totalSupply(), amount);
  }

  function testMinterGating() public {
    vm.prank(alice);
    vm.expectRevert(
      "AccessControl: account 0x328809bc894f92807417d2dad6b7c998c1afdac6 is missing role 0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6"
    );
    war.mint(bob, 100);

    vm.prank(admin);
    war.grantRole(MINTER_ROLE, alice);
    vm.prank(alice);
    war.mint(bob, 100);

    vm.prank(admin);
    war.revokeRole(MINTER_ROLE, alice);
    vm.prank(alice);
    vm.expectRevert(
      "AccessControl: account 0x328809bc894f92807417d2dad6b7c998c1afdac6 is missing role 0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6"
    );
    war.mint(bob, 100);
  }

  function testAdminCantMint() public {
    vm.prank(admin);
    vm.expectRevert(
      "AccessControl: account 0xaa10a84ce7d9ae517a52c6d5ca153b369af99ecf is missing role 0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6"
    );
    war.mint(bob, 500);
  }

  function testBurnerCantMint() public {
    vm.prank(burner);
    vm.expectRevert(
      "AccessControl: account 0xaefbc8c4b051e5a401b27034c18304ae75411b8f is missing role 0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6"
    );
    war.mint(bob, 500);
  }

  function testNoRoleCantMint() public {
    vm.prank(alice);
    vm.expectRevert(
      "AccessControl: account 0x328809bc894f92807417d2dad6b7c998c1afdac6 is missing role 0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6"
    );
    war.mint(bob, 2501);
  }
}
