// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarCvxCrvStakerTest.sol";

contract Stake is WarCvxCrvStakerTest {
  function _stake(address source, uint256 amount) internal {
    vm.assume(amount > 0 && amount <= IERC20(source).balanceOf(controller));
    vm.startPrank(controller);
    cvxCrvStaker.stake(source, amount);
    vm.stopPrank();
    // TODO check balances
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
    cvxCrvStaker.stake(source, 500);
  }

  function testZeroValue() public {
    vm.startPrank(controller);
    vm.expectRevert(Errors.ZeroValue.selector);
    cvxCrvStaker.stake(address(crv), 0);
    vm.expectRevert(Errors.ZeroValue.selector);
    cvxCrvStaker.stake(address(cvxCrv), 0);
    vm.stopPrank();
  }

  // TODO check yield
}
