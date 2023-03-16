// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./HarvestableTest.sol";

contract RemoveReward is HarvestableTest {
  function testDefaultBehavior(uint256 numberOfRewards, uint256 randomIndex) public {
    vm.assume(numberOfRewards > 0 && numberOfRewards <= 100);

    address[] memory rewards = generateAddressArray(numberOfRewards);

    vm.startPrank(admin);
    for (uint256 i; i < rewards.length; ++i) {
      if (rewards[i] != zero) {
        dummyHarvestable.addReward(rewards[i]);
      }
    }
    vm.stopPrank();

    uint256 addedRewardsLength = dummyHarvestable.rewardTokens().length;

    vm.assume(addedRewardsLength != 0);

    randomIndex = randomIndex % addedRewardsLength;
    address randomReward = dummyHarvestable.rewardTokens()[randomIndex];

    vm.prank(admin);
    dummyHarvestable.removeReward(randomReward);

    assertEq(
      dummyHarvestable.rewardTokens().length,
      addedRewardsLength - 1,
      "The length of the array should be decresed by 1 after removal"
    );

    for (uint256 i; i < dummyHarvestable.rewardTokens().length; ++i) {
      assertTrue(
        dummyHarvestable.rewardTokens()[i] != randomReward, "the selected token should have been removed from the array"
      );
    }
  }

  function testRewardNotInArray(uint256 numberOfRewards, address randomReward) public {
    vm.assume(randomReward != zero);
    vm.assume(numberOfRewards <= 100);

    address[] memory rewards = generateAddressArray(numberOfRewards);

    vm.startPrank(admin);
    for (uint256 i; i < rewards.length; ++i) {
      if (rewards[i] != zero) {
        vm.assume(randomReward != rewards[i]);
        dummyHarvestable.addReward(rewards[i]);
      }
    }
    vm.stopPrank();

    vm.expectRevert(Errors.NotRewardToken.selector);

    vm.prank(admin);
    dummyHarvestable.removeReward(randomReward);
  }

  function testOnlyOwner(address reward) public {
    vm.expectRevert("Ownable: caller is not the owner");

    dummyHarvestable.removeReward(reward);
  }

  function testZeroAddress() public {
    vm.expectRevert(Errors.ZeroAddress.selector);

    vm.prank(admin);
    dummyHarvestable.removeReward(zero);
  }
}
