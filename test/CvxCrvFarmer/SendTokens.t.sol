// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./CvxCrvFarmerTest.sol";

contract SendTokens is CvxCrvFarmerTest {
  function setUp() public override {
    CvxCrvFarmerTest.setUp();
    vm.startPrank(controller);
    cvxCrvFarmer.stake(address(cvxCrv), cvxCrv.balanceOf(controller));
    cvxCrvFarmer.stake(address(crv), crv.balanceOf(controller));
    vm.stopPrank();
    vm.warp(block.timestamp + 100 days);
  }

  function testDefaultBehavior(uint256 amount) public {
    vm.assume(amount > 0 && amount <= convexCvxCrvStaker.balanceOf(address(cvxCrvFarmer)));
    assertEq(cvxCrv.balanceOf(alice), 0);
    assertEq(convexCvxCrvStaker.balanceOf(address(cvxCrvFarmer)), 200e18);
    vm.prank(address(warStaker));
    cvxCrvFarmer.sendTokens(alice, amount);
    assertEq(cvxCrv.balanceOf(alice), amount);
  }

  function testZeroAmount(address randomAddress) public {
    vm.assume(randomAddress != zero);
    vm.expectRevert(Errors.ZeroValue.selector);
    vm.prank(address(warStaker));
    cvxCrvFarmer.sendTokens(randomAddress, 0);
  }

  function testZeroAddress(uint256 randomValue) public {
    vm.assume(randomValue > 0 && randomValue <= convexCvxCrvStaker.balanceOf(address(cvxCrvFarmer)));
    vm.expectRevert(Errors.ZeroAddress.selector);
    vm.prank(address(warStaker));
    cvxCrvFarmer.sendTokens(zero, randomValue);
  }

  function testOnlyWarStaker() public {
    vm.expectRevert(Errors.CallerNotAllowed.selector);
    cvxCrvFarmer.sendTokens(alice, 500);
  }
}
