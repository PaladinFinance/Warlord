// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./StakerTest.sol";

contract GetRewardTokens is StakerTest {
  function testDefaultBehavior(uint256 seed, uint256[] memory amounts) public {
    address[] memory rewardTokens = generateAddressArrayFromHash(seed, amounts.length);
    for (uint256 i; i < amounts.length; ++i) {
      vm.prank(swapper);
      amounts[i] = amounts[i] % 1e77 + 1;
      staker.queueRewards(rewardTokens[i], amounts[i]);
    }

    address[] memory rewardsAdded = staker.getRewardTokens();
    assertEq(
      rewardsAdded.length,
      rewardTokens.length,
      "The added rewards array's length should be the same as the amount of queued tokens"
    );
    for (uint256 i; i < rewardsAdded.length; ++i) {
      assertEq(rewardsAdded[i], rewardTokens[i], "The added rewards should correspond to the queued ones");
    }
  }
}
