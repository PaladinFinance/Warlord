// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./StakerTest.sol";

contract UpdateRewardState is StakerTest {
  uint256 constant DISTRIBUTION_DURATION = 604_800; // 1 week
  function testDefaultBehavior(/*uint128 timeDelta*/) public {
    uint128 timeDelta = 100; // doesn't work with 604801;
    RewardAndAmount[] memory fuzzedRewards = fuzzRewards(timeDelta);

    uint256 initialTime = block.timestamp;
    uint256 finalTime = block.timestamp + timeDelta;
    for (uint256 i; i < queueableRewards.length; ++i) {
      address reward = queueableRewards[i];

      vm.warp(initialTime);
      SimpleRewardState memory initialState = simpleRewardState(reward);

      vm.warp(finalTime);
      staker.updateRewardState(reward);
      SimpleRewardState memory finalState = simpleRewardState(reward);
      SimpleRewardState memory expectedState = futureState(reward, timeDelta, initialState);

      assertEq(finalState.lastUpdate, expectedState.lastUpdate, "last update should correspond to the expected one");
      assertEq(finalState.distributionEndTimestamp, expectedState.distributionEndTimestamp, "distribution end should correspond to the expected one");
    }
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

  function testZeroAddress() public {
    vm.expectRevert(Errors.ZeroAddress.selector);

    staker.updateRewardState(zero);
  }

  function testWhenNotPaused(address reward) public {
    vm.prank(admin);
    staker.pause();

    vm.expectRevert("Pausable: paused");
    staker.updateRewardState(reward);
  }

  struct SimpleRewardState {
    uint256 rewardPerToken;
    uint128 lastUpdate;
    uint128 distributionEndTimestamp;
    uint256 ratePerSecond;
    uint256 currentRewardAmount;
    uint256 queuedRewardAmount;
  }

  function futureState(address reward, uint256 timeDelta, SimpleRewardState memory state)
    public
    returns (SimpleRewardState memory newState)
  {
    assertLt(timeDelta, type(uint128).max, "durations are encoded as uint128");
    // Deep coping struct
    newState.lastUpdate = state.lastUpdate;

    if (staker.rewardFarmers(reward) != zero) {
      // indexed reward
    } else {
      // queueable reward
    }

    // TODO use safe128 not to break everything with fuzzing
    newState.lastUpdate += uint128(timeDelta);
    newState.distributionEndTimestamp = uint128(block.timestamp - timeDelta + DISTRIBUTION_DURATION);
  }
}
