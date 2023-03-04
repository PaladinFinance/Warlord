// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./StakerTest.sol";

contract ClaimRewards is StakerTest {
  function testClaimWithSingleStaker(address receiver, uint256 time, uint256[] calldata rewardsAmount) public {
    vm.assume(time < 1000 days);
    vm.assume(rewardsAmount.length >= queueableRewards.length);
    vm.assume(receiver != zero && receiver != address(staker));

    // Queues some random rewards from the queueable ones
    for (uint256 i; i < queueableRewards.length; ++i) {
      uint256 amount = rewardsAmount[i];
      if (amount == 0) continue;
      if (amount > 1e60) amount = amount % 1e60;
      _queue(queueableRewards[i], amount);
    }

    // TODO Queues some random rewards from the farmable ones

    _stake(alice, 1000e18);

    vm.warp(block.timestamp + time);

    WarStaker.UserClaimableRewards[] memory rewards = staker.getUserTotalClaimableRewards(alice);

    for (uint256 i; i < rewards.length; ++i) {
      IERC20 reward = IERC20(rewards[i].reward);

      vm.prank(alice);
      staker.claimRewards(address(reward), receiver);

      assertEqDecimal(
        reward.balanceOf(receiver), rewards[i].claimableAmount, 18, "receiver should have received the claimable amount"
      );
    }
  }

  function testWithMultipleStakers() public {
    // TODO
  }
  function testClaimAfterUnstake() public {
    // TODO
  }

  function testClaimNoRewards(address reward, address receiver) public {
    vm.assume(receiver != zero && reward != zero);

    vm.prank(alice);
    assertEq(staker.claimRewards(reward, receiver), 0, "should return 0 when no rewards available");
  }

  function testZeroReceiver(address reward) public {
    vm.assume(reward != zero);

    vm.expectRevert(Errors.ZeroAddress.selector);

    staker.claimRewards(reward, zero);
  }

  function testZeroReward(address receiver) public {
    vm.assume(receiver != zero);

    vm.expectRevert(Errors.ZeroAddress.selector);

    staker.claimRewards(zero, receiver);
  }

  function testNonReentrant() public {
    // TODO
  }

  function testWhenNotPaused(address reward, address receiver) public {
    vm.assume(receiver != zero);
    vm.assume(reward != zero);

    vm.prank(admin);
    staker.pause();

    vm.expectRevert("Pausable: paused");

    staker.claimRewards(reward, receiver);
  }
}
