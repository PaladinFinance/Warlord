// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarCvxCrvStakerTest.sol";

contract Stake is WarCvxCrvStakerTest {
  function _stake(address source, uint256 amount) internal {
    vm.assume(amount > 0 && amount <= IERC20(source).balanceOf(controller));
    // Initial staked amount is 0 in all groups
    assertEq(convexCvxCrvStaker.balanceOf(address(warCvxCrvStaker)), 0);
    assertEq(convexCvxCrvStaker.userRewardBalance(address(warCvxCrvStaker), 0), 0);
    assertEq(convexCvxCrvStaker.userRewardBalance(address(warCvxCrvStaker), 1), 0);
    // Initial index is 0
    assertEq(warCvxCrvStaker.getCurrentIndex(), 0);

    vm.startPrank(controller);
    warCvxCrvStaker.stake(source, amount);
    vm.stopPrank();

    // Balance gets updated to staked amount
    assertEq(convexCvxCrvStaker.balanceOf(address(warCvxCrvStaker)), amount);
    // Balance is all in group 0
    assertEq(convexCvxCrvStaker.userRewardBalance(address(warCvxCrvStaker), 0), amount);
    assertEq(convexCvxCrvStaker.userRewardBalance(address(warCvxCrvStaker), 1), 0);
    // Index increases accordingly
    assertEq(warCvxCrvStaker.getCurrentIndex(), amount);
  }

  function testDefaultBehaviorCrv(uint256 amount) public {
    _stake(address(crv), amount);
  }

  function testDefaultBehaviorCvxCrv(uint256 amount) public {
    _stake(address(cvxCrv), amount);
  }

  function testWrongSource(address source) public {
    vm.assume(source != address(cvxCrv) && source != address(crv));
    vm.prank(controller);
    vm.expectRevert(Errors.IncorrectToken.selector);
    warCvxCrvStaker.stake(source, 500);
  }

  function testZeroValue() public {
    vm.startPrank(controller);
    vm.expectRevert(Errors.ZeroValue.selector);
    warCvxCrvStaker.stake(address(crv), 0);
    vm.expectRevert(Errors.ZeroValue.selector);
    warCvxCrvStaker.stake(address(cvxCrv), 0);
    vm.stopPrank();
  }
}
