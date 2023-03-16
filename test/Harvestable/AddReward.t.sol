// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./HarvestableTest.sol";

contract AddReward is HarvestableTest {
  function testDefaultBehavior(uint256 numberOfRewards) public {
    vm.assume(numberOfRewards < 100);

    address[] memory rewards = generateAddressArray(numberOfRewards);

    uint256 nullRewards;
    uint256 previousLength;

    vm.startPrank(admin);
    for (uint256 i; i < rewards.length; ++i) {
      if (rewards[i] != zero) {
        dummyHarvestable.addReward(rewards[i]);
        assertEq(
          dummyHarvestable.rewardTokens()[i - nullRewards], rewards[i], "assigned reward should be the correct one"
        );
        assertEq(
          dummyHarvestable.rewardTokens().length,
          previousLength + 1,
          "the lenght of the array should have increased by one"
        );
        previousLength = dummyHarvestable.rewardTokens().length;
      } else {
        ++nullRewards;
      }
    }
    vm.stopPrank();
  }

  function testAlreadySet(uint256 numberOfRewards, uint256 duplicateRewardIndex) public {
    vm.assume(numberOfRewards < 100);

    address[] memory rewards = generateAddressArray(numberOfRewards);

    vm.startPrank(admin);
    for (uint256 i; i < rewards.length; ++i) {
      if (rewards[i] != zero) {
        dummyHarvestable.addReward(rewards[i]);
      }
    }
    vm.stopPrank();

    vm.assume(dummyHarvestable.rewardTokens().length != 0);

    duplicateRewardIndex = duplicateRewardIndex % dummyHarvestable.rewardTokens().length;
    address duplicateReward = dummyHarvestable.rewardTokens()[duplicateRewardIndex];

    vm.expectRevert(Errors.AlreadySet.selector);

    vm.prank(admin);
    dummyHarvestable.addReward(duplicateReward);
  }

  function testOnlyOwner(address reward) public {
    vm.expectRevert("Ownable: caller is not the owner");

    dummyHarvestable.addReward(reward);
  }

  function testZeroAddress() public {
    vm.expectRevert(Errors.ZeroAddress.selector);

    vm.prank(admin);
    dummyHarvestable.addReward(zero);
  }
}
