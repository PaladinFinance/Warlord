// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarCvxCrvStakerTest.sol";

contract SendTokens is WarCvxCrvStakerTest {
  function setUp() public override {
    WarCvxCrvStakerTest.setUp();
    vm.startPrank(controller);
    warCvxCrvStaker.stake(address(cvxCrv), cvxCrv.balanceOf(controller));
    warCvxCrvStaker.stake(address(crv), crv.balanceOf(controller));
    vm.stopPrank();
  }

  function testDefaultBehavior(uint256 amount) public {
    vm.assume(amount > 0 && amount <= convexCvxCrvStaker.balanceOf(address(warCvxCrvStaker)));
    assertEq(cvxCrv.balanceOf(alice), 0);
    assertEq(convexCvxCrvStaker.balanceOf(address(warCvxCrvStaker)), 200e18);
    vm.prank(address(warStaker));
    warCvxCrvStaker.sendTokens(alice, amount);
    assertEq(cvxCrv.balanceOf(alice), amount);
  }
  // TODO check after rewards are accrued

  function testZeroAmount(address randomAddress) public {
    vm.assume(randomAddress != zero);
    vm.expectRevert(Errors.ZeroValue.selector);
    vm.prank(address(warStaker));
    warCvxCrvStaker.sendTokens(randomAddress, 0);
  }

  function testZeroAddress(uint256 randomValue) public {
    vm.assume(randomValue > 0 && randomValue <= convexCvxCrvStaker.balanceOf(address(warCvxCrvStaker)));
    vm.expectRevert(Errors.ZeroAddress.selector);
    vm.prank(address(warStaker));
    warCvxCrvStaker.sendTokens(zero, randomValue);
  }
}
