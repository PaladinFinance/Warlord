// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./TokenTest.sol";

contract Transfer is TokenTest {
  function testDefaultBehavior(uint256 amountMint, uint256 amountTransfer) public {
    vm.assume(amountMint > 0 && amountMint >= amountTransfer);
    assertEq(war.totalSupply(), 0);
    assertEq(war.balanceOf(alice), 0);
    assertEq(war.balanceOf(bob), 0);
    vm.prank(minter);
    war.mint(alice, amountMint);
    assertEq(war.totalSupply(), amountMint);
    assertEq(war.balanceOf(alice), amountMint);
    assertEq(war.balanceOf(bob), 0);
    vm.prank(alice);
    war.transfer(bob, amountTransfer);
    assertEq(war.totalSupply(), amountMint);
    assertEq(war.balanceOf(alice), amountMint - amountTransfer);
    assertEq(war.balanceOf(bob), amountTransfer);
  }
}
