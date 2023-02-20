// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./CvxLockerTest.sol";

contract Harvest is CvxLockerTest {
  function setUp() public override {
    CvxLockerTest.setUp();
    uint256 amountToStake = cvx.balanceOf(address(minter));
    vm.prank(address(minter));
    locker.lock(amountToStake);
  }

  function testDefaultBehavior(uint256 time) public {
    vm.assume(time < 10_000 days);

    _assertNoPendingRewards();

    vm.warp(block.timestamp + time);

    (uint256 cvxCrvRewards, uint256 cvxFxsRewards) = _getRewards();
    locker.harvest();

    // check accrued rewards harvest to controller
    assertEq(cvxCrvRewards, cvxCrv.balanceOf(controller), "expecting no pending rewards for cvxCrv");
    assertEq(cvxFxsRewards, cvxFxs.balanceOf(controller), "expecting no pending rewards for cvxFxs");

    // check there's no rewards lefts after harvesting
    _assertNoPendingRewards();
  }
}
