// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./StakerTest.sol";

contract AddRewardDepositor is StakerTest {
  function setUp() public override {
    StakerTest.setUp();

    // Removes preset configs for staker
    vm.prank(admin);
    staker = new WarStaker(address(war));
  }

  function testDefaultBehavior(address depositor) public {
    vm.assume(depositor != zero);

    assertFalse(staker.rewardDepositors(depositor), "the reward depositor should initially not be allowed");

    vm.expectEmit(false, false, false, true);
    emit AddedRewardDepositor(depositor);

    vm.prank(admin);
    staker.addRewardDepositor(depositor);

    assertTrue(staker.rewardDepositors(depositor), "the reward depositor should now be allowed");
  }

  function testOnlyOwner(address depositor) public {
    vm.expectRevert("Ownable: caller is not the owner");
    staker.addRewardDepositor(depositor);
  }

  function testZeroDepositor() public {
    vm.prank(admin);

    vm.expectRevert(Errors.ZeroAddress.selector);
    staker.addRewardDepositor(zero);
  }

  function testAlreadyListedDepositor(address depositor) public {
    vm.assume(depositor != zero);

    vm.startPrank(admin);
    staker.addRewardDepositor(depositor);

    vm.expectRevert(Errors.AlreadyListedDepositor.selector);
    staker.addRewardDepositor(depositor);
    vm.stopPrank();
  }
}
