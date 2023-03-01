// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./StakerTest.sol";

contract Unstake is StakerTest {
  function setUp() public override {
    StakerTest.setUp();

    deal(address(war), alice, 10_000e18);
    vm.startPrank(alice);
    war.approve(address(staker), type(uint256).max);
    staker.stake(war.balanceOf(alice), alice);
    vm.stopPrank();
  }

  function testDeafultBehavior(uint256 amount, address receiver) public {
    vm.assume(receiver != address(staker) && receiver != alice);
    vm.assume(receiver != zero);
    uint256 initialStakedBalance = staker.balanceOf(alice);
    vm.assume(amount > 0 && amount < initialStakedBalance);

    assertEq(war.balanceOf(receiver), 0, "receiver shouldn't own any war tokens");
    assertEq(staker.balanceOf(alice), initialStakedBalance, "alice should have staked some war tokens");

    vm.expectEmit(true, true, false, true);
    emit Unstaked(alice, receiver, amount);

    vm.prank(alice);
    uint256 returnedAmount = staker.unstake(amount, receiver);

    assertEq(returnedAmount, amount, "returned amount should equal the unstaked amount");
    assertEq(amount, war.balanceOf(receiver), "unstaked amount should be correctly received by the receiver");
    assertEq(initialStakedBalance - amount, staker.balanceOf(alice), "amount should be deducted from staked balance");
  }

  function testUnstakeWholeBalance(uint256 initialUnstake, address receiver) public {
    vm.assume(receiver != zero && receiver != address(staker) && receiver != alice);
    vm.assume(initialUnstake > 0 && initialUnstake < staker.balanceOf(alice));

    // Remove an initial amount to shuffle the max staked balance
    vm.prank(alice);
    staker.unstake(initialUnstake, alice);

    uint256 balanceToUnstake = staker.balanceOf(alice);
    assertGt(balanceToUnstake, 0, "sanity check to make sure there's something to unstake");

    vm.prank(alice);
    staker.unstake(type(uint256).max, receiver);

    assertEq(war.balanceOf(receiver), balanceToUnstake, "whole staked balance should be unstaked to receiver");
  }

  function testZeroAmount(address receiver) public {
    vm.assume(receiver != zero);
    vm.expectRevert(Errors.ZeroValue.selector);

    vm.prank(alice);
    staker.unstake(0, receiver);
  }

  function testZeroBalance() public {
    vm.expectRevert(Errors.ZeroValue.selector);

    vm.prank(bob);
    staker.unstake(type(uint256).max, bob);
  }

  function testZeroReceiver(uint256 amount) public {
    vm.assume(amount > 0);

    vm.expectRevert(Errors.ZeroAddress.selector);

    vm.prank(alice);
    staker.unstake(amount, zero);
  }

  function testNonReentrant() public {
    // TODO
  }
}
