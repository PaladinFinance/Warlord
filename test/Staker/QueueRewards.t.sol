// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./StakerTest.sol";

contract QueueRewards is StakerTest {
  uint256 constant DISTRIBUTION_DURATION = 604_800; // 1 week
  uint256 private constant UPDATE_REWARD_RATIO = 8500; // 85 %

  struct SimpleRewardState {
    uint256 rewardPerToken;
    uint128 lastUpdate;
    uint128 distributionEndTimestamp;
    uint256 ratePerSecond;
    uint256 currentRewardAmount;
    uint256 queuedRewardAmount;
  }

  function simpleRewardState(address reward) public view returns (SimpleRewardState memory state) {
    (
      uint256 rewardPerToken,
      uint128 lastUpdate,
      uint128 distributionEndTimestamp,
      uint256 ratePerSecond,
      uint256 currentRewardAmount,
      uint256 queuedRewardAmount
    ) = staker.rewardStates(reward);
    state = SimpleRewardState(
      rewardPerToken, lastUpdate, distributionEndTimestamp, ratePerSecond, currentRewardAmount, queuedRewardAmount
    );
  }

  function testDefaultBehavior(uint256 amount) public {
    (address sender, address reward) = randomQueueableReward(amount);

    vm.assume(amount > 0 && amount < IERC20(reward).balanceOf(sender));

    // Sanity check in case of wrong setup
    assertGt(amount, 0, "the token balance queued is bigger than 0");

    SimpleRewardState memory prevState = simpleRewardState(reward);
    bool newReward = prevState.lastUpdate == 0 ? true : false;

    uint256 currentTs = block.timestamp;

    vm.expectEmit();
    emit NewRewards(reward, amount, currentTs + DISTRIBUTION_DURATION);

    vm.prank(sender);
    assertTrue(staker.queueRewards(reward, amount));

    SimpleRewardState memory state = simpleRewardState(reward);

    if(newReward) {
      address[] memory rewardTokens = staker.getRewardTokens();
      assertEq(rewardTokens[rewardTokens.length - 1], reward, "the reward token should be the last one in the list");
    }

    assertEq(state.queuedRewardAmount, 0); // new distribution, nothing in the queue

    uint256 exepctedRatePerSec = amount / DISTRIBUTION_DURATION;
    assertEq(state.ratePerSecond, exepctedRatePerSec);
    assertEq(state.currentRewardAmount, amount);
    assertEq(state.lastUpdate, currentTs);
    assertEq(state.distributionEndTimestamp, currentTs + DISTRIBUTION_DURATION);
    assertEq(state.rewardPerToken, prevState.rewardPerToken);


  }

  function testQueueWithActiveDistribution(uint256 amount, uint256 seed, uint256 timeDelta) public {
    vm.assume(timeDelta > 0);
    vm.assume(timeDelta <= (604_805 * 2));
    
    fuzzStakers(seed, 3);
    fuzzRewards(seed, true, false);
    
    (address sender, address reward) = randomQueueableReward(amount);

    vm.assume(amount > 0 && amount < IERC20(reward).balanceOf(sender));

    // Sanity check in case of wrong setup
    assertGt(amount, 0, "the token balance queued is bigger than 0");

    vm.warp(block.timestamp + timeDelta);

    SimpleRewardState memory prevState = simpleRewardState(reward);

    uint256 totalQueued = prevState.queuedRewardAmount + amount;
    uint256 undistributedAmount;
    uint256 expectedQueuedAmount;
    uint256 expectedAccruedAmount;
    bool onlyQueued = false;
    
    if(block.timestamp < prevState.distributionEndTimestamp) {
      undistributedAmount = prevState.ratePerSecond * (prevState.distributionEndTimestamp - block.timestamp);

      uint256 queuedAmountRatio = (totalQueued * 10_000) / (totalQueued + undistributedAmount);

      if(queuedAmountRatio < UPDATE_REWARD_RATIO) {
        expectedQueuedAmount = totalQueued;
        onlyQueued = true;
      }

      expectedAccruedAmount = (block.timestamp - prevState.lastUpdate) * prevState.ratePerSecond;

    } else {
      prevState.currentRewardAmount;

      expectedAccruedAmount = (prevState.distributionEndTimestamp - prevState.lastUpdate) * prevState.ratePerSecond;
    }

    vm.prank(sender);
    assertTrue(staker.queueRewards(reward, amount));

    SimpleRewardState memory state = simpleRewardState(reward);

    assertEq(
      state.rewardPerToken,
      prevState.rewardPerToken + ((expectedAccruedAmount * 1e18) / staker.totalSupply())
    );

    assertEq(state.queuedRewardAmount, expectedQueuedAmount);

    if(onlyQueued) {
      assertEq(state.ratePerSecond, prevState.ratePerSecond);
      assertEq(state.currentRewardAmount, prevState.currentRewardAmount);
      assertEq(state.lastUpdate, block.timestamp);
      assertEq(state.distributionEndTimestamp, prevState.distributionEndTimestamp);
    } else {
      assertEq(state.ratePerSecond, (amount + undistributedAmount) / DISTRIBUTION_DURATION);
      assertEq(state.currentRewardAmount, amount + undistributedAmount);
      assertEq(state.lastUpdate, block.timestamp);
      assertEq(state.distributionEndTimestamp, block.timestamp + DISTRIBUTION_DURATION);
    }
  }

  function testZeroAmount(uint256 seed) public {
    (address sender, address reward) = randomQueueableReward(seed);

    vm.expectRevert(Errors.ZeroValue.selector);

    vm.prank(sender);
    staker.queueRewards(address(reward), 0);
  }

  function testZeroRewardToken(uint256 amount) public {
    vm.assume(amount > 0);

    vm.expectRevert(Errors.ZeroAddress.selector);

    vm.prank(swapper);
    staker.queueRewards(zero, amount);
  }

  function testOnlyRewardDepositor(uint256 amount) public {
    vm.expectRevert(Errors.CallerNotAllowed.selector);
    staker.queueRewards(address(weth), amount);
  }

  function testWhenNotPaused() public {
    vm.prank(admin);
    staker.pause();

    vm.expectRevert("Pausable: paused");

    vm.prank(swapper);
    staker.queueRewards(address(weth), 1e18);
  }
}
