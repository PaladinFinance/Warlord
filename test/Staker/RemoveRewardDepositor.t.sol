// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./StakerTest.sol";

contract RemoveRewardDepositor is StakerTest {
  function setUp() public override {
    StakerTest.setUp();

    // Removes preset configs for staker
    vm.prank(admin);
    staker = new WarStaker(address(war));
  }

  function testDefaultBehavior(address depositor) public {
    vm.assume(depositor != zero);

    vm.startPrank(admin);
    staker.addRewardDepositor(depositor);

    assertTrue(staker.rewardDepositors(depositor), "the depositor should be initially whilelisted");

    vm.expectEmit(false, false, false, true);
    emit RemovedRewardDepositor(depositor);

    staker.removeRewardDepositor(depositor);

    assertFalse(staker.rewardDepositors(depositor), "the depositor should be removed");
    vm.stopPrank();
  }

  function testOnlyOwner(address depositor) public {
    vm.expectRevert("Ownable: caller is not the owner");
    staker.removeRewardDepositor(depositor);
  }

  function testZeroDepositor() public {
    vm.prank(admin);

    vm.expectRevert(Errors.ZeroAddress.selector);
    staker.removeRewardDepositor(zero);
  }

  function testNotListedDepositor(address depositor) public {
    vm.assume(depositor != zero);

    vm.expectRevert(Errors.NotListedDepositor.selector);

    vm.startPrank(admin);
    staker.removeRewardDepositor(depositor);
  }
}
