// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./StakerTest.sol";

contract GetUserAccruedRewards is StakerTest {
  function testDefaultBehavior(/* uint256 seed */) public {
    // vm.assume(seed > 100 && seed < 1 weeks);
    uint256 seed = 1;
    (address[] memory stakers, RewardAndAmount[] memory rewards) = fuzzRewardsAndStakers(seed, 10);
    vm.warp(block.timestamp + seed);

    console.log(vm.getLabel(rewards[1].reward));
    uint256 previousRewards = staker.getUserAccruedRewards(stakers[0], rewards[1].reward);
    console.log(rewards[1].amount);
    console.log("before ", previousRewards);

    // address[] memory unstakers = fuzzUnstakers(seed, stakers);

    
    // uint256 state = vm.snapshot();
    // for (uint256 i; i < unstakers.length; ++i){
    //   for (uint256 j; j < rewards.length; ++j) {
    //     uint256 previousRewards = staker.getUserAccruedRewards(unstakers[i], rewards[j].reward);
    //     vm.warp(block.timestamp + 10 weeks);
        // console.log("before ", previousRewards);
    //     assertEqDecimal(previousRewards, staker.getUserAccruedRewards(unstakers[i], rewards[j].reward), 18, "Rewards shouldn't have increase since unstake");
    //     vm.revertTo(state);
    //   }
    // }

    // bool atLeastOneGreaterAccruedReward;
    // for (uint256 i; i < stakers.length; ++i) {
    //   for (uint256 j; j < rewards.length; ++j) {
    //     if (rewards[j].reward == address(cvxCrv) || rewards[j].reward == address(auraBal)) continue;
    //     vm.revertTo(state);
    //     uint256 previousRewards = staker.getUserAccruedRewards(stakers[i], rewards[j].reward);
    //     vm.warp(block.timestamp + 1 weeks);
    //     uint256 currentRewards = staker.getUserAccruedRewards(stakers[i], rewards[j].reward);
    //     console.log("before ", previousRewards);
    //     console.log("after ", currentRewards);
    //     if (currentRewards > previousRewards) atLeastOneGreaterAccruedReward = atLeastOneGreaterAccruedReward || true;
    //     assertGeDecimal(previousRewards, currentRewards, 18, "Rewards should have increase or at least be the same");
    //   }
    // }
    // // sanity check
    // assertTrue(atLeastOneGreaterAccruedReward);
  }

  function testRewardsDontAccrueAfterUnstake() public {

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
