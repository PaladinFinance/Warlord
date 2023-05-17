// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./AuraBalFarmerTest.sol";

contract SendTokens is AuraBalFarmerTest {
  function setUp() public override {
    AuraBalFarmerTest.setUp();
    vm.startPrank(controller);
    auraBalFarmer.stake(address(auraBal), auraBal.balanceOf(controller));
    auraBalFarmer.stake(address(bal), bal.balanceOf(controller));
    vm.stopPrank();
    vm.warp(block.timestamp + 100 days);
  }

  function testDefaultBehavior(uint256 amount) public {
    // Checkpoint of iniital staked balance of auraBal
    uint256 initialBalance = auraBalStaker.balanceOf(address(auraBalFarmer));

    // Tokens amount is non-zero and smaller than iniital balance
    vm.assume(amount > 0 && amount <= initialBalance);

    // Alice doesn't have any token before the transaction
    assertEq(auraBal.balanceOf(alice), 0);

    vm.prank(address(warStaker));
    auraBalFarmer.sendTokens(alice, amount);

    // make sure alice received the correct amount
    assertEq(auraBal.balanceOf(alice), amount);

    // Check if the amount unstaked is correct
    assertEq(auraBalStaker.balanceOf(address(auraBalFarmer)), initialBalance - amount);
  }

  function testUnstakingMoreThanBalance(uint256 amount) public {
    uint256 initialBalance = auraBalStaker.balanceOf(address(auraBalFarmer));
    vm.assume(amount > initialBalance);

    vm.expectRevert(Errors.UnstakingMoreThanBalance.selector);

    vm.prank(address(warStaker));
    auraBalFarmer.sendTokens(alice, amount);
  }
}
