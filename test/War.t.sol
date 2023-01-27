// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import {ERC20} from "solmate/tokens/ERC20.sol";
import "../src/War.sol";
import "forge-std/Test.sol";

contract WarTokenTest is Test {
  address alice = makeAddr("alice");
  address bob = makeAddr("bob");
  WarToken war;

  function setUp() public {
    war = new WarToken(alice, bob);
  }

  function testMint() public {
    vm.prank(bob);
    war.mint(alice, 100);
    console.log(war.balanceOf(alice));
  }
}
