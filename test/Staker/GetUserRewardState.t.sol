// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./StakerTest.sol";

contract GetUserRewardState is StakerTest {
  function testDefaultBehavior() public {
    (address[] memory stakers, RewardAndAmount[] memory rewards) = fuzzRewardsAndStakers(234908, 4);

    vm.warp(3 days);

    // vm.breakpoint("a");

    vm.prank(stakers[0]);
    staker.claimRewards(rewards[0].reward, stakers[0]);

    WarStaker.UserRewardState memory state = staker.getUserRewardState(rewards[0].reward, stakers[0]);
    console.log(state.lastRewardPerToken);
    console.log(state.accruedRewards);
  }
}
