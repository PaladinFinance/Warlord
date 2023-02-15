// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./TokenTest.sol";

contract Burn is TokenTest {
  function testDefaultBehavior(uint256 amount) public {
    assertEq(war.balanceOf(bob), 0);
    assertEq(war.totalSupply(), 0);
    vm.prank(minter);
    war.mint(bob, amount);
    assertEq(war.totalSupply(), amount);
    assertEq(war.balanceOf(bob), amount);
    vm.prank(burner);
    war.burn(bob, amount);
    assertEq(war.balanceOf(bob), 0);
    assertEq(war.totalSupply(), 0);
  }

  function testBurnerGating(uint256 amount) public {
    vm.prank(alice);
    vm.expectRevert(
      "AccessControl: account 0x328809bc894f92807417d2dad6b7c998c1afdac6 is missing role 0x3c11d16cbaffd01df69ce1c404f6340ee057498f5f00246190ea54220576a848"
    );
    war.burn(bob, amount);

    vm.prank(minter);
    war.mint(bob, amount);
    vm.prank(admin);
    war.grantRole(BURNER_ROLE, alice);
    vm.prank(alice);
    war.burn(bob, amount);

    vm.prank(admin);
    war.revokeRole(BURNER_ROLE, alice);
    vm.prank(alice);
    vm.expectRevert(
      "AccessControl: account 0x328809bc894f92807417d2dad6b7c998c1afdac6 is missing role 0x3c11d16cbaffd01df69ce1c404f6340ee057498f5f00246190ea54220576a848"
    );
    war.burn(bob, amount);
  }

  function testMinterCantBurn(uint256 amount) public {
    vm.prank(minter);
    vm.expectRevert(
      "AccessControl: account 0x030f6a4c5baa7350405fa8122cf458070abd1b59 is missing role 0x3c11d16cbaffd01df69ce1c404f6340ee057498f5f00246190ea54220576a848"
    );
    war.burn(bob, amount);
  }

  function testAdminCantBurn(uint256 amount) public {
    vm.prank(admin);
    vm.expectRevert(
      "AccessControl: account 0xaa10a84ce7d9ae517a52c6d5ca153b369af99ecf is missing role 0x3c11d16cbaffd01df69ce1c404f6340ee057498f5f00246190ea54220576a848"
    );
    war.burn(bob, amount);
  }

  function testNoRoleCantBurn(uint256 amount) public {
    vm.prank(alice);
    vm.expectRevert(
      "AccessControl: account 0x328809bc894f92807417d2dad6b7c998c1afdac6 is missing role 0x3c11d16cbaffd01df69ce1c404f6340ee057498f5f00246190ea54220576a848"
    );
    war.burn(bob, amount);
  }
}
