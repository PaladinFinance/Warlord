// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./StakerTest.sol";

contract SetRewardFarmer is StakerTest {
  function testDefaultBehavior(address rewardToken, address farmer) public {
    vm.assume(rewardToken != zero && farmer != zero);
    vm.prank(admin);
    staker.setRewardFarmer(rewardToken, farmer);
    staker.rewardFarmers(rewardToken);
  }

  function testZeroRewardToken() public {
  }

  function testZeroFarmer() public {
  }

  function testRewardTokenAlreadySet() public {

  }
}