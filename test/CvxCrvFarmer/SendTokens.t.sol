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
    // Checkpoint of iniital staked balance of auraBal
    uint256 initialBalance = convexCvxCrvStaker.balanceOf(address(cvxCrvFarmer));

    // Tokens amount is non-zero and smaller than iniital balance
    vm.assume(amount > 0 && amount <= initialBalance);

    // Alice doesn't have any token before the transaction
    assertEq(cvxCrv.balanceOf(alice), 0);

    vm.prank(address(warStaker));
    cvxCrvFarmer.sendTokens(alice, amount);

    // make sure alice received the correct amount
    assertEq(cvxCrv.balanceOf(alice), amount);

    // Check if the amount unstaked is correct
    assertEq(convexCvxCrvStaker.balanceOf(address(cvxCrvFarmer)), initialBalance - amount);
  }

  function testUnstakingMoreThanBalance(uint256 amount) public {
    uint256 initialBalance = convexCvxCrvStaker.balanceOf(address(cvxCrvFarmer));
    vm.assume(amount > initialBalance);

    vm.expectRevert(Errors.UnstakingMoreThanBalance.selector);

    vm.prank(address(warStaker));
    cvxCrvFarmer.sendTokens(alice, amount);
  }
}
