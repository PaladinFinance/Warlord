// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./StakerTest.sol";

contract Stake is StakerTest {
  function testDefaultBehavior(uint256 amount, address receiver) public {
    uint256 initialBalance = 10_000e18;
    vm.assume(amount > 0 && amount < initialBalance);

    deal(address(war), alice, initialBalance);

    _stakeAndCheck(amount, alice, receiver);
  }

  function testDepositWholeBalance(uint256 initialBalance, address receiver) public {
    vm.assume(initialBalance > 0);
    deal(address(war), alice, initialBalance);

    _stakeAndCheck(type(uint256).max, alice, receiver);
  }

  function testCantStakeZeroAmount() public {
    vm.expectRevert(Errors.ZeroValue.selector);
    staker.stake(0, alice);
  }

  function testCantStakeWithZeroAddressReceiver() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    staker.stake(1e18, zero);
  }

  function _stakeAndCheck(uint256 amount, address sender, address receiver) internal {
    uint256 initialBalance = war.balanceOf(sender);

    vm.assume(sender != zero && receiver != zero);

    vm.prank(sender);
    war.approve(address(staker), type(uint256).max);

    assertEq(war.balanceOf(address(staker)), 0, "initial war balance in staker should be zero");
    assertEq(staker.balanceOf(receiver), 0, "initial staked balance should be zero");

    vm.startPrank(sender);

    uint256 actualAmount = amount == type(uint256).max ? initialBalance : amount;

    vm.expectEmit(true, true, false, true);
    emit Staked(sender, receiver, actualAmount); // TODO test this

    staker.stake(amount, receiver);

    vm.stopPrank();

    assertEq(war.balanceOf(sender), initialBalance - actualAmount, "sender war tokens should be deducted after staking");
    assertEq(war.balanceOf(address(staker)), actualAmount, "contract should have received sender's war tokens");
    assertEq(staker.balanceOf(receiver), actualAmount, "receiver should have a corresponding amount of staked tokens");
  }
}
