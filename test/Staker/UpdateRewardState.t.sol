// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./StakerTest.sol";
import {IFarmer} from "interfaces/IFarmer.sol";

contract UpdateRewardState is StakerTest {
  uint256 constant DISTRIBUTION_DURATION = 604_800; // 1 week

  function testDefaultBehavior(uint128 timeDelta) public {
    vm.assume(timeDelta > 0);
    vm.assume(timeDelta <= 604_805);

    /*RewardAndAmount[] memory fuzzedRewards = */
    fuzzRewardsAndStakers(timeDelta, 3); // need stakers so the staked supply is not 0 & the rewardPerToken is updated

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
      assertEq(
        finalState.distributionEndTimestamp,
        expectedState.distributionEndTimestamp,
        "distribution end should correspond to the expected one"
      );
      assertEq(
        finalState.queuedRewardAmount,
        expectedState.queuedRewardAmount,
        "queue reward amount should correspond to the expected one"
      );
      assertEq(
        finalState.ratePerSecond, expectedState.ratePerSecond, "rate per second should correspond to the expected one"
      );
      assertEq(
        finalState.currentRewardAmount,
        expectedState.currentRewardAmount,
        "current reward amount should correspond to the expected one"
      );
      assertEq(
        finalState.rewardPerToken,
        expectedState.rewardPerToken,
        "current reward amount should correspond to the expected one"
      );
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

    newState.distributionEndTimestamp = uint128(block.timestamp - timeDelta + DISTRIBUTION_DURATION);
    newState.lastUpdate =
      timeDelta > 1 weeks ? newState.distributionEndTimestamp : state.lastUpdate + uint128(timeDelta);
    // Independent from time changes
    newState.queuedRewardAmount = state.queuedRewardAmount;
    newState.ratePerSecond = state.ratePerSecond;
    newState.currentRewardAmount = state.currentRewardAmount;

    uint256 totalAccruedAmount;
    bool skip;
    if (staker.rewardFarmers(reward) != zero) {
      // indexed reward
      uint256 currentFarmerIndex = IFarmer(staker.rewardFarmers(reward)).getCurrentIndex();
      totalAccruedAmount = currentFarmerIndex - staker.farmerLastIndex(reward);
    } else {
      // queueable reward
      uint256 rewardEndTimestamp = state.distributionEndTimestamp;
      uint256 lastRewardTimestamp = block.timestamp > rewardEndTimestamp ? rewardEndTimestamp : block.timestamp;
      if (state.lastUpdate == lastRewardTimestamp) {
        newState.rewardPerToken = state.rewardPerToken;
        skip = true;
      }
      totalAccruedAmount = (lastRewardTimestamp - state.lastUpdate) * state.ratePerSecond;
    }
    if (!skip) {
      uint256 totalStakedSupply = staker.totalSupply();
      if (totalStakedSupply == 0) {
        newState.rewardPerToken = state.rewardPerToken;
      } else {
        newState.rewardPerToken = state.rewardPerToken + ((totalAccruedAmount * 1e18) / totalStakedSupply);
      }
    }
  }
}
