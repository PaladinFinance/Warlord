// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./StakerTest.sol";

contract ClaimAllRewards is StakerTest {
  address receiver = makeAddr("receiver");

  function testClaimAllSingleStaker(uint256 time) public withRewards {
    // uint256 time = 50 days;
    vm.assume(time < 1000 days);

    address user = makeAddr("user");

    console.log("STAKE CALL");
    _stake(user, (time % uint160(receiver)) + 1);

    vm.warp(block.timestamp + time);

    WarStaker.UserClaimableRewards[] memory expectedRewards = staker.getUserTotalClaimableRewards(user);

    console.log("CLAIM CALL");
    vm.prank(user);
    WarStaker.UserClaimedRewards[] memory returnedRewards = staker.claimAllRewards(receiver);
    assertEq(
      expectedRewards.length,
      queueableRewards.length + 2,
      "The number of rewards should be the number of queueable rewards + 2 indexed rewards"
    );
    assertEq(expectedRewards.length, returnedRewards.length, "The arrays with the rewards should have the same length");

    for (uint256 i; i < expectedRewards.length; ++i) {
      assertEqDecimal(
        returnedRewards[i].amount,
        expectedRewards[i].claimableAmount,
        18,
        "the amount of reward token should correspond"
      );
      assertEq(returnedRewards[i].reward, expectedRewards[i].reward, "reward token should correspond");
    }
    // assertFalse(true);
  }
}
