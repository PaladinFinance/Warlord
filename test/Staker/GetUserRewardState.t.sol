// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./StakerTest.sol";

contract GetUserRewardState is StakerTest {
  function testDefaultBehavior() public {
    (address[] memory stakers, RewardAndAmount[] memory rewards) = fuzzRewardsAndStakers(234_908, 4);

    vm.warp(block.timestamp + 9 weeks);
    staker.updateAllRewardStates();

    for (uint256 i; i < rewards.length; ++i) {
      address reward = rewards[i].reward;
      uint256 rewardAmount = rewards[i].amount;
      uint256 rewardSum;
      for (uint256 j; j < stakers.length; ++j) {
        if (i == 0) {
          uint256 amount = staker.balanceOf(stakers[j]);
          vm.prank(stakers[j]);
          staker.unstake(amount, stakers[j]);
        }

        WarStaker.UserRewardState memory state = staker.getUserRewardState(reward, stakers[j]);
        uint256 lastRewardPerToken = state.lastRewardPerToken;
        rewardSum += state.accruedRewards;

        vm.prank(stakers[j]);
        staker.claimRewards(reward, stakers[j]);

        state = staker.getUserRewardState(rewards[i].reward, stakers[j]);
        assertEqDecimal(state.accruedRewards, 0, 18, "There should be no accrued rewards after claim");
        assertGtDecimal(state.lastRewardPerToken, 0, 18, "Last reward sanity check");
        assertEqDecimal(
          state.lastRewardPerToken, lastRewardPerToken, 18, "Last reward per token shouldn't have changed after claim"
        );
      }
      assertApproxEqAbs(
        rewardSum, rewardAmount, 1e6, "The sum all last reward of each staker should coorespond to the sum"
      );
    }
  }
}
