// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarMinterTest.sol";

contract Mint is WarMinterTest {
  // TODO test for emits
  function _mint(address source, uint256 amount, address receiver) internal {
    vm.assume(receiver != alice && receiver != zero);
    vm.assume(amount > 0 && amount <= IERC20(source).balanceOf(alice));
    assertEq(war.totalSupply(), 0);
    assertEq(war.balanceOf(alice), 0);
    assertEq(war.balanceOf(receiver), 0);
    vm.prank(alice);
    minter.mint(source, amount, receiver);
    assertEq(war.totalSupply(), amount * 15);
    assertEq(war.balanceOf(alice), 0);
    assertEq(war.balanceOf(receiver), amount * 15);
  }

  function _mintWithImplicitReceiver(address source, uint256 amount) internal {
    vm.assume(amount > 0 && amount <= IERC20(source).balanceOf(alice));
    assertEq(war.totalSupply(), 0);
    assertEq(war.balanceOf(alice), 0);
    vm.prank(alice);
    minter.mint(source, amount);
    assertEq(war.totalSupply(), amount * 15); // TODO make a getter for mint ratio
    assertEq(war.balanceOf(alice), amount * 15);
  }

  function testDefaultBehaviorCvx(uint256 amount, address receiver) public {
    _mint(address(cvx), amount, receiver);
  }

  function testDefaultBehaviorCvxWithImplicitReceiver(uint256 amount) public {
    _mintWithImplicitReceiver(address(cvx), amount);
  }

  function testDefaultBehaviorAura(uint256 amount, address receiver) public {
    // TODO _mint(address(aura), amount, receiver);
  }

  function testDefaultBehaviorAuraWithImplicitReceiver(uint256 amount) public {
    // TODO _mintWithImplicitReceiver(address(aura), amount);
  }

  function testZeroAddress(uint256 amount) public {
    vm.assume(amount > 0);
    vm.prank(alice);
    vm.expectRevert(Errors.ZeroAddress.selector);
    minter.mint(address(cvx), amount, zero);
  }

  function testZeroLocker(uint256 amount) public {
    vm.assume(amount > 0);
    vm.prank(alice);
    vm.expectRevert(Errors.ZeroAddress.selector);
    minter.mint(zero, amount);
  }

  function testWithoutLocker(address vlToken) public {
    vm.assume(vlToken != zero);
    vm.assume(vlToken != address(cvx));
    vm.assume(vlToken != address(aura));
    vm.prank(alice);
    vm.expectRevert(Errors.NoWarLocker.selector);
    minter.mint(vlToken, 1e18);
  }

  function testMintAmountMustBeGreaterThanZero() public {
    vm.prank(alice);
    vm.expectRevert(Errors.ZeroValue.selector);
    minter.mint(address(aura), 0);
  }

  function testRevertsWithZeroMintAmount() public {
    MockMintRatio(address(mintRatio)).setRatio(address(cvx), 0);
    vm.prank(alice);
    vm.expectRevert(Errors.ZeroMintAmount.selector);
    minter.mint(address(cvx), 1e18);
  }
}
