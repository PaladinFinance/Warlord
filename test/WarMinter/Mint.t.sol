// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarMinterTest.sol";

contract Mint is WarMinterTest {
  function testMint(uint256 cvxAmount, uint256 auraAmount) public {
    // TODO is test also required with higher balances ?
    vm.assume(cvxAmount <= cvx.balanceOf(alice));
    vm.assume(auraAmount <= aura.balanceOf(alice));
    vm.assume(cvxAmount + auraAmount > 0);
    assertEq(war.totalSupply(), 0);
    assertEq(war.balanceOf(alice), 0);
    assertEq(war.balanceOf(bob), 0);
    vm.prank(alice);
    minter.mint(cvxAmount, auraAmount, bob);
    assertEq(war.totalSupply(), cvxAmount + auraAmount);
    assertEq(war.balanceOf(alice), 0);
    assertEq(war.balanceOf(bob), cvxAmount + auraAmount);
  }

  function testMintWithImplicitReceiver(uint256 cvxAmount, uint256 auraAmount) public {
    vm.assume(cvxAmount <= cvx.balanceOf(alice));
    vm.assume(auraAmount <= aura.balanceOf(alice));
    vm.assume(cvxAmount + auraAmount > 0);

    assertEq(war.totalSupply(), 0);
    assertEq(war.balanceOf(alice), 0);

    vm.prank(alice);
    minter.mint(cvxAmount, auraAmount);

    assertEq(war.totalSupply(), cvxAmount + auraAmount);
    assertEq(war.balanceOf(alice), cvxAmount + auraAmount);
    assertEq(cvx.balanceOf(alice), 100 ether - cvxAmount);
    assertEq(aura.balanceOf(alice), 100 ether - auraAmount);
  }

  function testCantMintToZeroAddress() public {
    vm.prank(alice);
    vm.expectRevert("zero address"); // TODO use proper errors
    minter.mint(1 ether, 1 ether, address(0));
  }

  function testTotalAmountMustBeGreaterThanZero() public {
    vm.prank(alice);
    vm.expectRevert("not sending any token"); // TODO use proper errors
    minter.mint(0, 0, bob);
  }
}
