// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarStakerTest.sol";

contract Stake is WarStakerTest {
  function testNormalBehavior(uint256 amount) public {
    // TODO init in the ts tests guess it was removed
    // TODO more assertions
		// TODO missing getters that would make tests more accurate? like userCurrentStakedAmount
    vm.assume(amount > 0 && amount < war.balanceOf(alice));
    vm.startPrank(alice);

    // Checking initial balance
    assertEq(war.balanceOf(alice), 100 ether);
    assertEq(war.balanceOf(address(staker)), 0);

    // Check emits
    vm.expectEmit(true, true, false, true);
    emit Transfer(alice, address(staker), amount);
    vm.expectEmit(true, true, false, true);
    emit Staked(alice, alice, amount);

    // Staking
    staker.stake(amount, alice);

    // Checking balance after staking
    assertEq(war.balanceOf(alice), 100 ether - amount);
    assertEq(war.balanceOf(address(staker)), amount);

    vm.stopPrank();
  }

  function testDepositWholeBalance() public {
    vm.startPrank(alice);
    assertEq(war.balanceOf(alice), 100 ether);
    war.approve(address(staker), type(uint256).max);
    staker.stake(type(uint256).max, alice);
    assertEq(war.balanceOf(alice), 0);
    vm.stopPrank();
  }

  function testCantStakeZeroAmount() public {
    vm.expectRevert(Errors.ZeroValue.selector);
    staker.stake(0, alice);
  }

  function testCantStakeWithZeroAddressReceiver() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    staker.stake(1 ether, zero);
  }
}
