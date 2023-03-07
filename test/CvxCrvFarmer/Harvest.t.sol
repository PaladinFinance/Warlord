// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./CvxCrvFarmerTest.sol";

contract Harvest is CvxCrvFarmerTest {
  function setUp() public override {
    CvxCrvFarmerTest.setUp();
    vm.startPrank(controller);
    cvxCrvFarmer.stake(address(cvxCrv), cvxCrv.balanceOf(controller));
    cvxCrvFarmer.stake(address(crv), crv.balanceOf(controller));
    vm.stopPrank();
  }

  function _defaultBehavior(uint256 time) internal {
    _assertNoPendingRewards();

    vm.warp(block.timestamp + time);
    (uint256 crvRewards, uint256 cvxRewards, uint256 threeCrvRewards) = _getRewards();
    cvxCrvFarmer.harvest();

    assertEq(crv.balanceOf(controller), crvRewards);
    assertEq(cvx.balanceOf(controller), cvxRewards);
    assertEq(threeCrv.balanceOf(controller), threeCrvRewards);

    _assertNoPendingRewards();
  }

  function testDefaultBehavior(uint256 weight, uint256 time) public {
    vm.assume(weight >= 0 && weight < 10_000);
    vm.assume(time < 10_000 days);
    vm.prank(admin);
    cvxCrvFarmer.setRewardWeight(weight);
    _defaultBehavior(time);
  }

  function testWhenNotPaused() public {
    vm.prank(admin);
    cvxCrvFarmer.pause();
    vm.expectRevert("Pausable: paused");
    cvxCrvFarmer.harvest();
  }
}
