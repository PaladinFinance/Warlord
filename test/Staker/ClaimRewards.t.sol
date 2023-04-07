// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./StakerTest.sol";

contract ClaimRewards is StakerTest {
  address receiver = makeAddr("receiver");

  function testClaimSingleStaker(uint256 time) public withRewards(time) {
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
    vm.assume(stakedWarAmount > 0);
    vm.assume(rewardsAmount > 1e18 && rewardsAmount < AURA_MAX_SUPPLY);

    stakedWarAmount = stakedWarAmount % WAR_SUPPLY_UPPER_BOUND;

    // Gives to the address the amount and stakes it
    _stake(address(this), stakedWarAmount);

    // Adds farmable rewards to staker
    _increaseIndex(address(auraBal), rewardsAmount);
    _increaseIndex(address(cvxCrv), rewardsAmount);

    // Check that delcared claim amount corresponds to actual one
    assertEqDecimal(
      staker.claimRewards(address(auraBal), receiver),
      auraBal.balanceOf(receiver),
      18,
      "auraBal Rewards should be claimed correctly"
    );
    assertEqDecimal(
      staker.claimRewards(address(cvxCrv), receiver),
      cvxCrv.balanceOf(receiver),
      18,
      "cvxCrv Rewards should be claimed correctly"
    );

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

  function testDebug(uint256 seed) public withRewards(seed) {}

  function testClaimFromNotStaker(uint256 seed, uint256 numberOfStakers) public withRewards(seed) {
    fuzzStakers(seed, numberOfStakers);
    address notStaker = makeAddr("notStaker");

    vm.startPrank(notStaker);
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

  function testWithMultipleStakers(uint256 seed, uint256 numberOfStakers) public withRewards(seed) {
    address[] memory stakers = fuzzStakers(seed, numberOfStakers);
    // TODO implementation
  }

  function testClaimAfterUnstake() public {
    // TODO implementation
  }

  function testMultipleClaims() public {
    // TODO implementation
  }

  function testClaimNoRewards(address reward) public {
    vm.assume(reward != zero);

    // TODO caller should be a staker

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
