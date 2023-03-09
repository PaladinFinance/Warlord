// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./CvxLockerTest.sol";

contract Harvest is CvxLockerTest {
  function setUp() public override {
    CvxLockerTest.setUp();
    _assertNoPendingRewards();
    _mockMultipleLocks(1e25);
  }

  function testDefaultBehavior(uint256 time) public {
    vm.assume(time < 10_000 days);

    vm.warp(block.timestamp + time);

    (uint256 cvxCrvRewards, uint256 cvxFxsRewards, uint256 fxsRewards) = _getRewards();
    locker.harvest();

    // check accrued rewards harvest to controller
    assertEqDecimal(
      cvxCrv.balanceOf(controller), cvxCrvRewards, 18, "cvxCrv pending rewards should be transfered to controller "
    );
    assertEqDecimal(
      cvxFxs.balanceOf(controller), cvxFxsRewards, 18, "cvxFxs pending rewards should be transfered to controller"
    );
    assertEqDecimal(fxs.balanceOf(controller), fxsRewards, 18, "fxs pending rewards should be transfered to controller");

    // check there's no rewards lefts after harvesting
    _assertNoPendingRewards();
  }
}
