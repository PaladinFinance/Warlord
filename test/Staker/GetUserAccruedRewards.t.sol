// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./StakerTest.sol";

contract GetUserAccruedRewards is StakerTest {
  function testDefaultBehavior(uint256 seed) public {
    vm.assume(seed > 100 && seed < 1 weeks);
    // uint256 seed = 10;
    (address[] memory stakers, RewardAndAmount[] memory rewards) = fuzzRewardsAndStakers(seed, 10);
    vm.warp(block.timestamp + seed);

    address[] memory unstakers = fuzzUnstakers(seed, stakers);

    uint256 state = vm.snapshot();
    for (uint256 i; i < unstakers.length; ++i) {
      for (uint256 j; j < rewards.length; ++j) {
        uint256 previousRewards = staker.getUserAccruedRewards(unstakers[i], rewards[j].reward);
        vm.warp(block.timestamp + 10 weeks);
        assertGt(previousRewards, 0, "accrued rewards should be greater than zero");
        assertEqDecimal(
          previousRewards,
          staker.getUserAccruedRewards(rewards[j].reward, unstakers[i]),
          18,
          "Rewards shouldn't have increase since unstake"
        );
        vm.revertTo(state);
      }
    }

    bool atLeastOneGreaterAccruedReward;
    for (uint256 i; i < stakers.length; ++i) {
      for (uint256 j; j < rewards.length; ++j) {
        if (rewards[j].reward == address(cvxCrv) || rewards[j].reward == address(auraBal)) continue;
        vm.revertTo(state);
        uint256 previousRewards = staker.getUserAccruedRewards(rewards[j].reward, stakers[i]);
        vm.warp(block.timestamp + 1 weeks);
        uint256 currentRewards = staker.getUserAccruedRewards(rewards[j].reward, stakers[i]);
        if (currentRewards > previousRewards) atLeastOneGreaterAccruedReward = atLeastOneGreaterAccruedReward || true;
        assertGeDecimal(currentRewards, previousRewards, 18, "Rewards should have increase or at least be the same");
      }
    }
    // sanity check
    assertTrue(atLeastOneGreaterAccruedReward, "at least one reward should have increase even considering unstakes");
  }

  function fuzzUnstakers(uint256 seed, address[] memory stakers) public returns (address[] memory unstakers) {
    if (stakers.length == 0) return new address[](0);
    uint256 unstakerIncrease = seed % stakers.length + 1;

    for (uint256 i = unstakerIncrease; i < stakers.length; i += unstakerIncrease) {
      address unstaker = stakers[i];
      vm.prank(stakers[i]);
      uint256 unstakerAmount = seed % staker.balanceOf(unstaker);
      if (unstakerAmount == 0) unstakerAmount = type(uint256).max;
      vm.prank(unstaker);
      staker.unstake(unstakerAmount, stakers[i]);
    }
  }
}
