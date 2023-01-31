// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarMinterTest.sol";

contract Mint is WarMinterTest {
  function testMintCvx(uint256 amount) public {
    // TODO is test also required with higher balances ?
    vm.assume(amount <= cvx.balanceOf(alice));
    vm.assume(amount > 0);
    assertEq(war.totalSupply(), 0);
    assertEq(war.balanceOf(alice), 0);
    assertEq(war.balanceOf(bob), 0);
    vm.prank(alice);
    minter.mint(address(cvx), amount, bob);
    assertEq(war.totalSupply(), amount);
    assertEq(war.balanceOf(alice), 0);
    assertEq(war.balanceOf(bob), amount);
  }

  function testMintWithImplicitReceiver(uint256 amount) public {
    vm.assume(amount <= cvx.balanceOf(alice));
    vm.assume(amount > 0);
    assertEq(war.totalSupply(), 0);
    assertEq(war.balanceOf(alice), 0);
    assertEq(war.balanceOf(bob), 0);
    vm.prank(alice);
    minter.mint(address(cvx), amount);
    assertEq(war.totalSupply(), amount);
    assertEq(war.balanceOf(alice), amount);
    assertEq(war.balanceOf(bob), 0);
  }

  function testCantMintToZeroAddress() public {
    /* vm.prank(alice);
    vm.expectRevert("zero address"); // TODO use proper errors
    minter.mint(1 ether, 1 ether, address(0)); */
  }

  function testTotalAmountMustBeGreaterThanZero() public {
    /* vm.prank(alice);
    vm.expectRevert("not sending any token"); // TODO use proper errors
    minter.mint(0, 0, bob); */
  }
}
