// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarCvxCrvStakerTest.sol";

contract SetWarStaker is WarCvxCrvStakerTest {
  function setUp() public override {
    WarCvxCrvStakerTest.setUp();
    vm.startPrank(controller);
    warCvxCrvFarmer.stake(address(cvxCrv), cvxCrv.balanceOf(controller));
    warCvxCrvFarmer.stake(address(crv), crv.balanceOf(controller));
    vm.stopPrank();
  }

  function testDefaultBehavior() public {
    _assertNoPendingRewards();

    vm.startPrank(admin);
    warCvxCrvFarmer.setRewardWeight(0);
    vm.warp(block.timestamp + 1);

    (uint256 crvRewards, uint256 cvxRewards, uint256 threeCrvRewards) = _getRewards();
    assertGt(crvRewards, 0);
    assertGt(cvxRewards, 0);
    assertEq(threeCrvRewards, 0);
    (uint256 oldCrvRewards, uint256 oldCvxRewards, uint256 oldThreeCrvRewards) =
      (crvRewards, cvxRewards, threeCrvRewards);

    warCvxCrvFarmer.harvest();

    for (uint256 i = 1; i < 10_000; i += 25) {
      // Lower the increase for a more precise test
      warCvxCrvFarmer.setRewardWeight(i);
      vm.warp(block.timestamp + 1);
      (crvRewards, cvxRewards, threeCrvRewards) = _getRewards();
      assertLt(crvRewards, oldCrvRewards);
      assertLt(cvxRewards, oldCvxRewards);
      assertGt(threeCrvRewards, oldThreeCrvRewards);

      // Setup for next cycle
      warCvxCrvFarmer.harvest();
      (oldCrvRewards, oldCvxRewards, oldThreeCrvRewards) = (crvRewards, cvxRewards, threeCrvRewards);
    }

    warCvxCrvFarmer.setRewardWeight(10_000);
    vm.warp(block.timestamp + 1);

    (crvRewards, cvxRewards, threeCrvRewards) = _getRewards();
    assertEq(crvRewards, 0);
    assertEq(cvxRewards, 0);
    assertGt(threeCrvRewards, 0);
    vm.stopPrank();
  }
}
