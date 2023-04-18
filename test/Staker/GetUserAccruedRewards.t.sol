// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./StakerTest.sol";

contract GetUserAccruedRewards is StakerTest {
  function testDefaultBehavior(uint256 seed) public {
    vm.assume(seed < 4 weeks);
    // uint256 seed = 1;
    (address[] memory stakers, RewardAndAmount[] memory rewards) = fuzzRewardsAndStakers(seed, 10);
    vm.warp(block.timestamp + seed);

    address[] memory unstakers = fuzzUnstakers(seed, stakers);

    for (uint256 i; i < stakers.length; ++i) {
      for (uint256 j; j < rewards.length; ++j) {
        uint256 accruedAmount = staker.getUserAccruedRewards(rewards[j].reward, stakers[i]);
      }
    }
  }

  function fuzzUnstakers(uint256 seed, address[] memory stakers) public returns (address[] memory unstakers) {
    /*for (uint256 i; i < stakers.length; ++i) {
      console.log(staker.balanceOf(stakers[i]));
    }*/

    if (stakers.length == 0) return new address[](0);
    uint256 unstakerIncrease = seed % stakers.length + 1;
    /*console.log(seed);
    console.log(stakers.length);
    console.log(unstakerIncrease);*/ 

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
