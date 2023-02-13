// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarCvxLockerTest.sol";

contract Harvest is WarCvxLockerTest {
  function setUp() public override {
    WarCvxLockerTest.setUp();
    uint256 amountToStake = cvx.balanceOf(address(minter));
    vm.prank(address(minter));
    locker.lock(amountToStake);
  }

  function testDefaultBehavior() public {
    // locker.harvest();
    // console.log(cvxCrv.balanceOf(controller));
    // console.log(cvxFxs.balanceOf(controller));
    vm.prank(vlCvx.owner());
    vlCvx.notifyRewardAmount(address(cvxCrv), 500);
    console.log(vlCvx.lockedBalanceOf(address(locker)));
    vm.warp(block.timestamp + 100 days);
    locker.harvest();
    // console.log(cvxCrv.balanceOf(controller));
    // console.log(cvxFxs.balanceOf(controller));
    assertTrue(false);
  }
}
