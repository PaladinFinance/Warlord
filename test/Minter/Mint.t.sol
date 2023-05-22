// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./MinterTest.sol";

contract Mint is MinterTest {
  // TODO test for emits
  function _mint(address source, uint256 amount, address receiver) internal {
    vm.assume(receiver != alice && receiver != zero);
    vm.assume(amount > 0 && amount <= IERC20(source).balanceOf(alice));
    assertEq(war.totalSupply(), 0);
    assertEq(war.balanceOf(alice), 0);
    assertEq(war.balanceOf(receiver), 0);
    vm.prank(alice);
    minter.mint(source, amount, receiver);
    uint256 expectedMintAmount = ratios.getMintAmount(source, amount);
    assertEq(war.totalSupply(), expectedMintAmount);
    // TODO assertEq(IERC20(source).balanceOf(alice), 0);
    assertEq(war.balanceOf(alice), 0);
    assertEq(war.balanceOf(receiver), expectedMintAmount);
  }

  function _mintWithImplicitReceiver(address source, uint256 amount) internal {
    vm.assume(amount > 0 && amount <= IERC20(source).balanceOf(alice));
    assertEq(war.totalSupply(), 0);
    assertEq(war.balanceOf(alice), 0);
    vm.prank(alice);
    minter.mint(source, amount);
    uint256 expectedMintAmount = ratios.getMintAmount(source, amount);
    assertEq(war.balanceOf(alice), expectedMintAmount);
  }

  function testDefaultBehavior(uint256 amount, address receiver) public {
    vm.assume(amount > 1e4);
    address token = randomVlToken(amount);
    _mint(token, amount, receiver);
  }

  function testDefaultBehaviorWithImplicitReceiver(uint256 amount) public {
    vm.assume(amount > 1e4);
    address token = randomVlToken(amount);
    _mintWithImplicitReceiver(token, amount);
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

  function testRevertsWithZeroMintAmount(uint256 amount) public {
    vm.assume(amount > 0 && amount < 1e4);

    vm.startPrank(admin);
    MockERC20 otherToken = new MockERC20();
    DummyLocker otherLocker = new DummyLocker(address(otherToken));
    minter.setLocker(address(otherToken), address(otherLocker));
    otherToken.mint(address(alice), 100e18);
    vm.stopPrank();
    ratios.addToken(address(otherToken), 1e30);

    vm.startPrank(alice);
    otherToken.approve(address(minter), 100e18);
    vm.expectRevert(Errors.ZeroMintAmount.selector);
    minter.mint(address(otherToken), amount);
    vm.stopPrank();
  }
}
