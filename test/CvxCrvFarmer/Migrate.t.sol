// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./CvxCrvFarmerTest.sol";

contract Migrate is CvxCrvFarmerTest {
  address migration = makeAddr("migration");

  function setUp() public override {
    CvxCrvFarmerTest.setUp();
    vm.startPrank(controller);
    cvxCrvFarmer.stake(address(cvxCrv), cvxCrv.balanceOf(controller));
    cvxCrvFarmer.stake(address(crv), crv.balanceOf(controller));
    vm.stopPrank();
    vm.warp(block.timestamp + 100 days);
    vm.prank(admin);
    cvxCrvFarmer.pause();
  }

  function testDefaultBehavior() public {
    (uint256 crvRewards, uint256 cvxRewards, uint256 threeCrvRewards) = _getRewards();

    uint256 stakedBalance = convexCvxCrvStaker.balanceOf(address(cvxCrvFarmer));
    assertEq(cvxCrv.balanceOf(migration), 0);

    vm.prank(admin);
    cvxCrvFarmer.migrate(migration);

    assertEq(cvxCrv.balanceOf(migration), stakedBalance);

    assertEq(crv.balanceOf(controller), crvRewards);
    assertEq(cvx.balanceOf(controller), cvxRewards);
    assertEq(threeCrv.balanceOf(controller), threeCrvRewards);

    _assertNoPendingRewards();
  }
}
