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
    assertEq(war.totalSupply(), amount * 15);
    assertEq(war.balanceOf(alice), 0);
    assertEq(war.balanceOf(bob), amount * 15);
  }

  function testMintCvxWithImplicitReceiver(uint256 amount) public {
    vm.assume(amount <= cvx.balanceOf(alice));
    vm.assume(amount > 0);
    assertEq(war.totalSupply(), 0);
    assertEq(war.balanceOf(alice), 0);
    assertEq(war.balanceOf(bob), 0);
    vm.prank(alice);
    minter.mint(address(cvx), amount);
    assertEq(war.totalSupply(), amount * 15);
    assertEq(war.balanceOf(alice), amount * 15);
    assertEq(war.balanceOf(bob), 0);
  }

  function testCantMintToZeroAddress(uint256 amount) public {
    vm.assume(amount > 0);
    vm.prank(alice);
    vm.expectRevert(Errors.ZeroAddress.selector);
    minter.mint(address(cvx), amount, address(0));
  }

  function testCantMintWithZeroLocker(uint256 amount) public {
    vm.assume(amount > 0);
    vm.prank(alice);
    vm.expectRevert(Errors.ZeroAddress.selector);
    minter.mint(address(0), amount);
  }

  function testCantMintWithoutLocker(address vlToken) public {
    vm.assume(vlToken != address(0));
    vm.assume(vlToken != address(cvx));
    vm.assume(vlToken != address(aura));
    vm.prank(alice);
    vm.expectRevert(Errors.NoWarLocker.selector);
    minter.mint(vlToken, 1 ether);
  }

  function testMintAmountMustBeGreaterThanZero() public {
    vm.prank(alice);
    vm.expectRevert(Errors.ZeroValue.selector);
    minter.mint(address(aura), 0);
  }
}
