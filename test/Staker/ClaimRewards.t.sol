// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./StakerTest.sol";

contract ClaimRewards is StakerTest {
  address receiver = makeAddr("receiver");
  address[] stakers;

  modifier withRewards() {
    uint256 rewardsAmount = 1e50;
    for (uint256 i; i < queueableRewards.length; ++i) {
      _queue(queueableRewards[i], rewardsAmount);
    }
    _;
  }

  modifier withStakers(uint256 seed, uint256 numberOfStakers) {
    vm.assume(numberOfStakers > 0);
    numberOfStakers = numberOfStakers % 100 + 1;
    // Using fixed seed for addresses to speedup fuzzing
    stakers = generateAddressArrayFromHash(12_345, numberOfStakers);
    uint256[] memory amounts =
      generateNumberArrayFromHash(seed, numberOfStakers, WAR_SUPPLY_UPPER_BOUND / numberOfStakers);
    for (uint256 i; i < numberOfStakers; ++i) {
      _stake(stakers[i], amounts[i]);
    }
    _;
  }

  function testClaimFromQueuedSingleStaker(uint256 time, uint256[] calldata rewardsAmount) public withRewards {
    vm.assume(time < 1000 days);
    vm.assume(rewardsAmount.length >= queueableRewards.length);

    address user = makeAddr("user");

    _stake(user, (time % uint160(receiver)) + 1);

    vm.warp(block.timestamp + time);

    WarStaker.UserClaimableRewards[] memory rewards = staker.getUserTotalClaimableRewards(user);

    for (uint256 i; i < rewards.length; ++i) {
      IERC20 reward = IERC20(rewards[i].reward);

      vm.prank(user);
      staker.claimRewards(address(reward), receiver);

      uint256 amount = rewards[i].claimableAmount;
      assertEqDecimal(reward.balanceOf(receiver), amount, 18, "receiver should have received the claimable amount");
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

  function testClaimFromNotStaker(uint256 seed, uint256 numberOfStakers)
    public
    withRewards
    withStakers(seed, numberOfStakers)
  {
    address notStaker = makeAddr("notStaker");

    vm.startPrank(notStaker);
    assertEqDecimal(
      staker.claimRewards(address(auraBal), receiver), 0, 18, "Someone not should claim 0 auraBal rewards"
    );
    assertEqDecimal(staker.claimRewards(address(cvxCrv), receiver), 0, 18, "Someone not should claim 0 cvxCrv rewards");
    vm.stopPrank();

    assertEqDecimal(
      auraBal.balanceOf(receiver), 0, 18, "Someone not staking should have 0 auraBal rewards after claiming"
    );
    assertEqDecimal(
      cvxCrv.balanceOf(receiver), 0, 18, "Someone not staking should have 0 cvxCrv rewards after claiming"
    );
  }

  function testWithMultipleStakers(uint256 seed, uint256 stakersAmount)
    public
    withRewards
    withStakers(seed, stakersAmount)
  {
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
