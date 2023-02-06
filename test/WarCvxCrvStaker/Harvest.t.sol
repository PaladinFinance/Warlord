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

  function testDefaultBehaviorWithGovernanceRewards() public {
    assertEq(cvxCrv.balanceOf(controller), 0);
    assertEq(crv.balanceOf(controller), 0);
    assertEq(threeCrv.balanceOf(controller), 0);

    warCvxCrvStaker.harvest();
    assertEq(cvxCrv.balanceOf(controller), 0);
    assertEq(crv.balanceOf(controller), 0);
    assertEq(threeCrv.balanceOf(controller), 0);

    vm.warp(block.timestamp + 100 days);
    warCvxCrvStaker.harvest();
    assertGt(crv.balanceOf(controller), 0);
    assertGt(cvx.balanceOf(controller), 0);
    assertEq(threeCrv.balanceOf(controller), 0);
  }

  function testDefaultBehaviorWithStableRewards() public {
    vm.prank(admin);
    warCvxCrvStaker.setRewardWeight(10_000);

    assertEq(cvxCrv.balanceOf(controller), 0);
    assertEq(crv.balanceOf(controller), 0);
    assertEq(threeCrv.balanceOf(controller), 0);

    warCvxCrvStaker.harvest();
    assertEq(cvxCrv.balanceOf(controller), 0);
    assertEq(crv.balanceOf(controller), 0);
    assertEq(threeCrv.balanceOf(controller), 0);

    vm.warp(block.timestamp + 100 days);
    warCvxCrvStaker.harvest();
    assertEq(crv.balanceOf(controller), 0);
    assertEq(cvx.balanceOf(controller), 0);
    assertGt(threeCrv.balanceOf(controller), 0);
  }

  function testDefaultBehaviorWithMixedRewards() public {
    vm.prank(admin);
    warCvxCrvStaker.setRewardWeight(5000);

    assertEq(cvxCrv.balanceOf(controller), 0);
    assertEq(crv.balanceOf(controller), 0);
    assertEq(threeCrv.balanceOf(controller), 0);

    warCvxCrvStaker.harvest();
    assertEq(cvxCrv.balanceOf(controller), 0);
    assertEq(crv.balanceOf(controller), 0);
    assertEq(threeCrv.balanceOf(controller), 0);

    vm.warp(block.timestamp + 100 days);
    warCvxCrvStaker.harvest();
    assertGt(crv.balanceOf(controller), 0);
    assertGt(cvx.balanceOf(controller), 0);
    assertGt(threeCrv.balanceOf(controller), 0);
  }
  //TODO maybe stronger tests?
}
