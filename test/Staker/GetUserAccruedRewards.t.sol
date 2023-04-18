// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./StakerTest.sol";

contract GetUserAccruedRewards is StakerTest {
  function testDefaultBehavior(uint256 seed) public {
    // uint256 seed = 1;
    (address[] memory stakers, RewardAndAmount[] memory rewards) = fuzzRewardsAndStakers(seed, 10);
    vm.warp(block.timestamp + seed);

    /*for (uint256 i; i < stakers.length; ++i) {
      vm.prank(stakers[i]);
      staker.unstake(type(uint256).max, stakers[i]);
    } */

    address[] memory unstakers = fuzzUnstakers(seed, stakers);

    for (uint256 i; i < stakers.length; ++i) {
      // console.log("new staker --------------");
      for (uint256 j; j < rewards.length; ++j) {
        uint256 accruedAmount = staker.getUserAccruedRewards(rewards[j].reward, stakers[i]);
        // console.log(accruedAmount);
      }
    }
  }

  function fuzzUnstakers(uint256 seed, address[] memory stakers) public returns (address[] memory unstakers) {
    for (uint256 i; i < stakers.length; ++i) {
      console.log(staker.balanceOf(stakers[i]));
    }

    if (stakers.length == 0) return new address[](0);
    uint256 unstakerIncrease = seed % stakers.length;

    for (uint256 i = unstakerIncrease; i < stakers.length; i += unstakerIncrease) {
      address unstaker = stakers[i];
      vm.prank(stakers[i]);
      uint256 unstakerAmount = seed % staker.balanceOf(unstaker);
      if (unstakerAmount == 0) unstakerAmount = type(uint256).max;
      vm.prank(unstaker);
      staker.unstake(unstakerAmount, stakers[i]);
      console.log(i);
    }

    console.log("done");

    for (uint256 i; i < stakers.length; ++i) {
      console.log(staker.balanceOf(stakers[i]));
    }
  }

}
