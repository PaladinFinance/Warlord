// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./StakerTest.sol";

contract ClaimRewards is StakerTest {
  address receiver = makeAddr("receiver");

  function testClaimSingleStaker(uint256 time) public {
    fuzzRewards(time);
    vm.assume(time < 1000 days);

    address user = makeAddr("user");

    _stake(user, (time % uint160(receiver)) + 1);

    vm.warp(block.timestamp + time);

    WarStaker.UserClaimableRewards[] memory rewards = staker.getUserTotalClaimableRewards(user);

    for (uint256 i; i < rewards.length; ++i) {
      IERC20 reward = IERC20(rewards[i].reward);

      vm.prank(user);
      uint256 claimedAmount = staker.claimRewards(address(reward), receiver);

      uint256 expectedAmount = rewards[i].claimableAmount;

      assertEqDecimal(claimedAmount, expectedAmount, 18, "the expected amount should correspond to the one claimed");
      assertEqDecimal(
        reward.balanceOf(receiver), expectedAmount, 18, "receiver should have received the claimable amount"
      );
    }
  }

  function testClaimRewardsFromFarmersSingleStaker(uint256 stakedWarAmount, uint256 rewardsAmount) public {
    // TODO edge case with [500000000000000000000000, 4092639850559004120564477695705666666666666666666]]
    vm.assume(stakedWarAmount > 0);
    vm.assume(rewardsAmount > 1e18 && rewardsAmount < 1e55);

    stakedWarAmount = stakedWarAmount % WAR_SUPPLY_UPPER_BOUND;

    // Gives to the address the amount and stakes it
    _stake(address(this), stakedWarAmount);

    // Adds farmable rewards to staker
    _increaseIndex(address(auraBal), rewardsAmount);
    _increaseIndex(address(cvxCrv), rewardsAmount);

    // Check that delcared claim amount corresponds to actual one
    uint256 auraBalClaimedAmount = staker.claimRewards(address(auraBal), receiver);
    assertGt(auraBalClaimedAmount, 0, "The amount claimed should be bigger than zero");
    assertEqDecimal(
      auraBal.balanceOf(receiver), auraBalClaimedAmount, 18, "auraBal Rewards should be claimed correctly"
    );

    uint256 cvxCrvClaimedAmount = staker.claimRewards(address(cvxCrv), receiver);
    assertGt(cvxCrvClaimedAmount, 0, "The amount claimed should be bigger than zero");
    assertEqDecimal(cvxCrv.balanceOf(receiver), cvxCrvClaimedAmount, 18, "cvxCrv Rewards should be claimed correctly");

    assertApproxEqAbs(
      auraBal.balanceOf(receiver),
      rewardsAmount,
      CLAIM_REWARDS_PRECISION_LOSS,
      "auraBal rewards claimed should be aproximatevly be the same as the ones added"
    );
    assertApproxEqAbs(
      cvxCrv.balanceOf(receiver),
      rewardsAmount,
      CLAIM_REWARDS_PRECISION_LOSS,
      "cvxCrv rewards claimed should be aproximatevly be the same as the ones added"
    );
  }

  function testClaimFromNotStaker(uint256 numberOfStakers) public {
    fuzzRewardsAndStakers(numberOfStakers, numberOfStakers);

    address notStaker = makeAddr("notStaker");

    vm.startPrank(notStaker);
    for (uint256 i; i < queueableRewards.length; ++i) {
      assertEqDecimal(
        staker.claimRewards(queueableRewards[i], receiver),
        0,
        18,
        "Someone not staking should claim 0 queueable rewards"
      );
    }

    assertEqDecimal(
      staker.claimRewards(address(auraBal), receiver), 0, 18, "Someone not staking should claim 0 auraBal rewards"
    );
    assertEqDecimal(
      staker.claimRewards(address(cvxCrv), receiver), 0, 18, "Someone not staking should claim 0 cvxCrv rewards"
    );
    vm.stopPrank();

    assertEqDecimal(
      auraBal.balanceOf(receiver), 0, 18, "Someone not staking should have 0 auraBal rewards after claiming"
    );
    assertEqDecimal(
      cvxCrv.balanceOf(receiver), 0, 18, "Someone not staking should have 0 cvxCrv rewards after claiming"
    );
  }

  function testWithMultipleStakers(uint256 time) public {
    vm.assume(time > 0 && time < 1000 days);
    uint256 STAKERS_UPPERBOUND = 10_000;
    uint256 numberOfStakers = time % STAKERS_UPPERBOUND + 1;

    (address[] memory stakers, RewardAndAmount[] memory rewards) = fuzzRewardsAndStakers(time, numberOfStakers);

    vm.warp(block.timestamp + time);

    for (uint256 i; i < rewards.length; ++i) {
      uint256 claimedAmount;
      for (uint256 j; j < stakers.length; ++j) {
        vm.prank(stakers[j]);
        claimedAmount += staker.claimRewards(rewards[i].reward, receiver);
        assertGt(claimedAmount, 0, "the amount claimed by a staker should always be > 0");
      }
      assertApproxEqAbs(
        IERC20(rewards[i].reward).balanceOf(receiver),
        claimedAmount,
        CLAIM_REWARDS_PRECISION_LOSS,
        "the sum of all the rewards claimed should be aproximatevly be the same as the ones added"
      );
    }
  }

  function testClaimAfterUnstake(uint256 time) public {
    /*
    uint256 STAKERS_UPPERBOUND = 3;
    uint256 numberOfStakers = time % STAKERS_UPPERBOUND + 1;

    vm.assume(time > 0 && time < 1000 days);
    (address[] memory stakers,RewardAndAmount[] memory rewards) = fuzzRewardsAndStakers(time, numberOfStakers);

    vm.warp(block.timestamp + time);

    WarStaker.UserClaimableRewards[][] memory rewardsPerUser = new WarStaker.UserClaimableRewards[][](stakers.length);

    for (uint256 i; i < stakers.length; ++i) {
      vm.prank(stakers[i]);
      staker.unstake(type(uint256).max, receiver);
      rewardsPerUser[i] = staker.getUserTotalClaimableRewards(stakers[i]);
    }

    vm.warp(block.timestamp + time);

    for (uint256 i; i < rewards.length; ++i) {
      for (uint256 j; j < stakers.length; ++j) {
        vm.prank(stakers[i]);
        uint256 claimedAmount = staker.claimRewards(rewards[i].reward, receiver);
        assertGt(claimedAmount, 0, "even after withdrawal accrued awards can be withdrawn");
      }
    }
    */
  }

  function testClaimAfterPartialUnstake() public {
    // TODO implementation
  }

  function testMultipleClaims() public {
    // TODO implementation
  }

  function testClaimNoRewards(address reward) public {
    vm.assume(reward != zero);

    // TODO more assertions

    assertEqDecimal(staker.claimRewards(reward, receiver), 0, 18, "should return 0 when no rewards available");
  }

  function testNoRewardsRightAfterClaim() public {
    // TODO implementation
  }

  function testNoRewardsRightAfterStake() public {
    // TODO implementation
  }

  function testZeroReceiver(address reward) public {
    vm.assume(reward != zero);

    vm.expectRevert(Errors.ZeroAddress.selector);

    staker.claimRewards(reward, zero);
  }

  function testZeroReward() public {
    vm.expectRevert(Errors.ZeroAddress.selector);

    staker.claimRewards(zero, receiver);
  }

  function testWhenNotPaused(address reward) public {
    vm.assume(reward != zero);

    vm.prank(admin);
    staker.pause();

    vm.expectRevert("Pausable: paused");

    staker.claimRewards(reward, receiver);
  }
}
