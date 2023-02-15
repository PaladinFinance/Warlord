// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./AuraBalFarmerTest.sol";

contract SendTokens is AuraBalFarmerTest {
/*
  function setUp() public override {
    WarAuraBalStakerTest.setUp();
    vm.startPrank(controller);
    warAuraBalStaker.stake(address(cvxCrv), cvxCrv.balanceOf(controller));
    warAuraBalStaker.stake(address(crv), crv.balanceOf(controller));
    vm.stopPrank();
    vm.warp(block.timestamp + 100 days);
  }

  function testDefaultBehavior(uint256 amount) public {
    vm.assume(amount > 0 && amount <= convexCvxCrvStaker.balanceOf(address(warAuraBalStaker)));
    assertEq(cvxCrv.balanceOf(alice), 0);
    assertEq(convexCvxCrvStaker.balanceOf(address(warAuraBalStaker)), 200e18);
    vm.prank(address(warStaker));
    warAuraBalStaker.sendTokens(alice, amount);
    assertEq(cvxCrv.balanceOf(alice), amount);
  }

  function testZeroAmount(address randomAddress) public {
    vm.assume(randomAddress != zero);
    vm.expectRevert(Errors.ZeroValue.selector);
    vm.prank(address(warStaker));
    warAuraBalStaker.sendTokens(randomAddress, 0);
  }

  function testZeroAddress(uint256 randomValue) public {
    vm.assume(randomValue > 0 && randomValue <= convexCvxCrvStaker.balanceOf(address(warAuraBalStaker)));
    vm.expectRevert(Errors.ZeroAddress.selector);
    vm.prank(address(warStaker));
    warCvxCrvFarmer.sendTokens(zero, randomValue);
  }*/
}
