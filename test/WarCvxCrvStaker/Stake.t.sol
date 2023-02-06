// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarCvxCrvStakerTest.sol";

contract Stake is WarCvxCrvStakerTest {
  function testDefaultBehaviorCrv(uint256 amount) public {
    vm.assume(amount > 0 && amount <= crv.balanceOf(controller));
    vm.startPrank(controller);
    crv.approve(address(cvxCrvStaker), crv.balanceOf(controller));
    cvxCrvStaker.stake(address(crv), amount);
    vm.stopPrank();
  }

  function testDefaultBehaviorCvxCrv(uint256 amount) public {
    vm.assume(amount > 0 && amount <= cvxCrv.balanceOf(controller));
    vm.startPrank(controller);
    cvxCrv.approve(address(cvxCrvStaker), cvxCrv.balanceOf(controller));
    cvxCrvStaker.stake(address(cvxCrv), amount);
    vm.stopPrank();
  }
}
