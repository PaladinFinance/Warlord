// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./StakerTest.sol";

contract QueueRewards is StakerTest {
  function setUp() override public {
    StakerTest.setUp();

    vm.startPrank(admin);
    staker.addRewardDepositor(controller);
    staker.addRewardDepositor(yieldDumper);
    vm.stopPrank();
  }
  function testDefaultBehavior(uint256 amount) public {
    (address sender, address reward) = randomQueueableReward(amount);

    vm.assume(amount > 0 && amount < IERC20(reward).balanceOf(sender));

    // Sanity check in case of wrong setup
    assertGt(amount, 0, "the token balance queued is bigger than 0");

    // TODO more assertions

    vm.prank(sender);
    assertTrue(staker.queueRewards(reward, amount));
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

    vm.prank(yieldDumper);
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

    vm.prank(yieldDumper);
    staker.queueRewards(address(weth), 1e18);
  }

  function testNonReentrant() public {
    // TODO
  }
}
