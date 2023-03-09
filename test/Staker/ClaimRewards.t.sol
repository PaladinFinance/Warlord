// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./StakerTest.sol";

contract ClaimRewards is StakerTest {
  function testClaimWithSingleStaker(address receiver, uint256 time, uint256[] calldata rewardsAmount) public {
    vm.assume(time < 1000 days);
    vm.assume(rewardsAmount.length >= queueableRewards.length);
    vm.assume(receiver != zero && receiver != address(staker));

    uint256 rewardUpperBound = 1e55;

    // Queues some random rewards from the queueable ones
    for (uint256 i; i < queueableRewards.length; ++i) {
      vm.assume(IERC20(queueableRewards[i]).balanceOf(receiver) == 0);
      uint256 amount = rewardsAmount[i];
      if (amount < 1e7) continue;
      if (amount > rewardUpperBound) amount = amount % rewardUpperBound;
      _queue(queueableRewards[i], amount);
    }

    // TODO Queues some random rewards from the farmable ones

    _stake(alice, (time % uint160(receiver)) + 1);

    vm.warp(block.timestamp + time);

    WarStaker.UserClaimableRewards[] memory rewards = staker.getUserTotalClaimableRewards(alice);

    for (uint256 i; i < rewards.length; ++i) {
      IERC20 reward = IERC20(rewards[i].reward);

      vm.prank(alice);
      staker.claimRewards(address(reward), receiver);

      uint256 amount = rewards[i].claimableAmount;
      assertEqDecimal(reward.balanceOf(receiver), amount, 18, "receiver should have received the claimable amount");
    }
  }

  struct PersonWithStake {
    address person;
    uint256 amount;
  }

  function testWithMultipleStakers(PersonWithStake[] calldata stakes) public {
    /*
    uint256 numberOfStakes = stakes.length;
    vm.assume(numberOfStakes > 0);
    uint256 totalStakedAmount;
    for (uint256 i; i < numberOfStakes; ++i) {
      PersonWithStake memory stake = stakes[i];
      stake.amount = stake.amount % 10_000e18;
      totalStakedAmount += stake.amount;
    }
    vm.assume(totalStakedAmount > 0);
    for (uint256 i; i < numberOfStakes; ++i) {
      PersonWithStake memory stake = stakes[i];
      _stake(stake.person, stake.amount);
    }
    */
    // TODO implementation
  }

  function testClaimAfterUnstake() public {
    // TODO implementation
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
    // TODO #4
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
