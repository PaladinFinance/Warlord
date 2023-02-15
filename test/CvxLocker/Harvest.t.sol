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

  function testDefaultBehavior() public {
    /*
    TODO 
    console.log(vlCvx.lockedBalanceOf(address(locker)));
    vm.prank(vlCvx.owner());
    vlCvx.notifyRewardAmount(address(cvxCrv), 500);
    locker.harvest();
    assertTrue(false);
    */
  }
}
