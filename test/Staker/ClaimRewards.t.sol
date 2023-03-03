// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./StakerTest.sol";

contract ClaimRewards is StakerTest {
  function setUp() public override {
    StakerTest.setUp();

    deal(address(war), alice, 10_000e18);

    vm.startPrank(alice);
    war.approve(address(staker), type(uint256).max);
    staker.stake(10_000e18, alice);
    vm.stopPrank();
  }

  function testDefaultBehavior(/*address receiver*/) public {
    // Queue some rewards
    // TODO generalize this with random address and random tokens
    // TODO fuzz rewardsAmount
    uint256 rewardsAmount = 1e18;
    vm.prank(yieldDumper);
    staker.queueRewards(address(pal), rewardsAmount);

    /* 
    vm.prank(alice);
    staker.claimRewards(address(weth), alice);
    console.log(weth.balanceOf(alice));
    */ 

    vm.warp(block.timestamp + 7 days);

    console.log(pal.balanceOf(address(staker)));
    vm.prank(alice);
    staker.claimRewards(address(pal), alice);
    console.log(pal.balanceOf(alice));
  }

  function testClaimNoRewards(address reward, address receiver) public {
    vm.assume(receiver != zero && reward != zero);

    vm.prank(alice);
    assertEq(staker.claimRewards(reward, receiver), 0, "should return 0 when no rewards available");
  }

  function testZeroReceiver(address reward) public {
    vm.assume(reward != zero);

    vm.expectRevert(Errors.ZeroAddress.selector);

    staker.claimRewards(reward, zero);
  }
  function testZeroReward(address receiver) public {
    vm.assume(receiver != zero);

    vm.expectRevert(Errors.ZeroAddress.selector);

    staker.claimRewards(zero, receiver);
  }

  function testNonReentrant() public {
    // TODO
  }
  function testWhenNotPaused(address reward, address receiver) public {
    vm.assume(receiver != zero);
    vm.assume(reward != zero);

    vm.prank(admin);
    staker.pause();

    vm.expectRevert("Pausable: paused");

    staker.claimRewards(reward, receiver);
  }
}
