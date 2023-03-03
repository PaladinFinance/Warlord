// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./StakerTest.sol";

contract SetRewardFarmer is StakerTest {
  function setUp() public override {
    StakerTest.setUp();

    // Removes preset configs for staker
    vm.prank(admin);
    staker = new WarStaker(address(war));
  }

  function testDefaultBehavior(address rewardToken) public {
    vm.assume(rewardToken != zero);

    address farmer = _generateFarmerWith(rewardToken);

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

  function testMismatchingFarmers(address rewardToken, address notRewardToken) public {
    vm.assume(rewardToken != zero && notRewardToken != zero && rewardToken != notRewardToken);

    address farmer = _generateFarmerWith(notRewardToken);

    vm.expectRevert(Errors.MismatchingFarmer.selector);

    vm.prank(admin);
    staker.setRewardFarmer(rewardToken, farmer);
  }

  function testOnlyOwner(address rewardToken, address farmer) public {
    vm.expectRevert("Ownable: caller is not the owner");
    staker.setRewardFarmer(rewardToken, farmer);
  }

  function _generateFarmerWith(address underlying) internal returns (address farmer) {
    vm.prank(admin);
    farmer = address(new WarDummyFarmerWithToken(underlying));
  }
}
