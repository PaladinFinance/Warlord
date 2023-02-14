// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarAuraBalFarmerTest.sol";

contract Harvest is WarAuraBalFarmerTest {
/*function setUp() public override {
    WarAuraBalFarmerTest.setUp();
    vm.startPrank(controller);
    warAuraBalFarmer.stake(address(auraBal), auraBal.balanceOf(controller));
    warAuraBalFarmer.stake(address(bal), bal.balanceOf(controller));
    vm.stopPrank();
  }

  function testRandom() public {
    console.log(_getRewards());
  } */

/*
  function _defaultBehavior(uint256 time) internal {
    _assertNoPendingRewards();

    vm.warp(block.timestamp + time);
    uint256 rewards = _getRewards();
    warAuraBalFarmer.harvest();

    assertEq(bal.balanceOf(controller), crvRewards);
    assertEq(cvx.balanceOf(controller), cvxRewards);
    assertEq(threeCrv.balanceOf(controller), threeCrvRewards);

    _assertNoPendingRewards();
  }

  function testDefaultBehavior(uint256 weight, uint256 time) public {
    vm.assume(weight >= 0 && weight < 10_000);
    vm.assume(time > 0 && time < 10_000 days);
    vm.prank(admin);
    warCvxCrvFarmer.setRewardWeight(weight);
    _defaultBehavior(time);
  }*/
}
