// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import {ERC20} from "solmate/tokens/ERC20.sol";
import "../src/War.sol";
import "forge-std/Test.sol";

contract WarTokenTest is Test {
  address admin = makeAddr("admin");
  address minter = makeAddr("minter");
  address alice = makeAddr("alice");
  address bob = makeAddr("bob");
  WarToken war;

  function setUp() public {
    war = new WarToken(admin);
  }

  function testMint() public {
    vm.prank(admin);
    war.grantMinterRole(alice);
    vm.prank(alice);
    war.mint(bob, 100);
    assertEq(war.balanceOf(bob), 100);
  }

  function testAdminGating() public {
    // TODO should I test for more than 1 admin
    vm.prank(alice);
    vm.expectRevert(
      "AccessControl: account 0x328809bc894f92807417d2dad6b7c998c1afdac6 is missing role 0x0000000000000000000000000000000000000000000000000000000000000000"
    );
    war.grantMinterRole(alice);
  }

  function testMinterGating() public {
    vm.prank(alice);
    vm.expectRevert(
      "AccessControl: account 0x328809bc894f92807417d2dad6b7c998c1afdac6 is missing role 0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6"
    );
    war.mint(bob, 100);

    vm.prank(admin);
    war.grantMinterRole(alice);
    vm.prank(alice);
    war.mint(bob, 100);

    vm.prank(admin);
    war.revokeMinterRole(alice);
    vm.prank(alice);
    vm.expectRevert(
      "AccessControl: account 0x328809bc894f92807417d2dad6b7c998c1afdac6 is missing role 0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6"
    );
    war.mint(bob, 100);
  }
}
