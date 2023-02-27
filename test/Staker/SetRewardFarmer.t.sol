// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./StakerTest.sol";

contract SetRewardFarmer is StakerTest {
  function testDefaultBehavior(address rewardToken, address farmer) public {
    vm.assume(rewardToken != zero && farmer != zero);

    vm.expectEmit(true, false, false, true);
    emit SetRewardFarmer(rewardToken, farmer);

    vm.prank(admin);
    staker.setRewardFarmer(rewardToken, farmer);

    assertEq(staker.rewardFarmers(rewardToken), farmer, "rewardToken should be associated to the corresponding farmer");
  }

  function testZeroRewardToken(address farmer) public {
    vm.assume(farmer != zero);

    vm.expectRevert(Errors.ZeroAddress.selector);

    vm.prank(admin);
    staker.setRewardFarmer(zero, farmer);
  }

  function testZeroFarmer(address rewardToken) public {
    vm.assume(rewardToken != zero);

    vm.expectRevert(Errors.ZeroAddress.selector);

    vm.prank(admin);
    staker.setRewardFarmer(rewardToken, zero);
  }

  function testZeroAddresses() public {
    vm.expectRevert(Errors.ZeroAddress.selector);

    vm.prank(admin);
    staker.setRewardFarmer(zero, zero);
  }

  function testRewardTokenAlreadySet(address rewardToken, address initialFarmer, address newFarmer) public {
    vm.assume(rewardToken != zero && initialFarmer != zero && newFarmer != zero);
    vm.assume(initialFarmer != newFarmer);

    vm.startPrank(admin);
    staker.setRewardFarmer(rewardToken, initialFarmer);

    vm.expectRevert(Errors.AlreadySetFarmer.selector);
    staker.setRewardFarmer(rewardToken, newFarmer);
    vm.stopPrank();
  }

  function testOnlyOwner(address rewardToken, address farmer) public {
    vm.expectRevert("Ownable: caller is not the owner");
    staker.setRewardFarmer(rewardToken, farmer);
  }
}
