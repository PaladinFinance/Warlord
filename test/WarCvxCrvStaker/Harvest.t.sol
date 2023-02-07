// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarCvxCrvStakerTest.sol";

contract Stake is WarCvxCrvStakerTest {
  function setUp() public override {
    WarCvxCrvStakerTest.setUp();
    vm.startPrank(controller);
    warCvxCrvStaker.stake(address(cvxCrv), cvxCrv.balanceOf(controller));
    warCvxCrvStaker.stake(address(crv), crv.balanceOf(controller));
    vm.stopPrank();
  }

  function _getRewards() internal returns (uint256 _crv, uint256 _cvx, uint256 _threeCrv) {
    CvxCrvStaker.EarnedData[] memory list = convexCvxCrvStaker.earned(address(warCvxCrvStaker));
    _crv = list[0].amount;
    _cvx = list[1].amount;
    _threeCrv = list[2].amount;
  }

  function _assertNoPendingRewards() internal {
    (uint256 crvRewards, uint256 cvxRewards, uint256 threeCrvRewards) = _getRewards();
    assertEq(crvRewards, 0);
    assertEq(cvxRewards, 0);
    assertEq(threeCrvRewards, 0);
  }

  function _defaultBehavior(uint256 time) internal {
    _assertNoPendingRewards();

    vm.warp(block.timestamp + time);
    (uint256 crvRewards, uint256 cvxRewards, uint256 threeCrvRewards) = _getRewards();
    warCvxCrvStaker.harvest();

    assertEq(crv.balanceOf(controller), crvRewards);
    assertEq(cvx.balanceOf(controller), cvxRewards);
    assertEq(threeCrv.balanceOf(controller), threeCrvRewards);

    _assertNoPendingRewards();
  }

  function testDefaultBehavior(uint256 weight, uint256 time) public {
    vm.assume(weight >= 0 && weight < 10_000);
    vm.assume(time > 0 && time < 10_000 days);
    vm.prank(admin);
    warCvxCrvStaker.setRewardWeight(weight);
    _defaultBehavior(time);
  }
}
