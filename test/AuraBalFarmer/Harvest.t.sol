// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./AuraBalFarmerTest.sol";

contract Harvest is AuraBalFarmerTest {
  function setUp() public override {
    AuraBalFarmerTest.setUp();
    vm.startPrank(controller);
    auraBalFarmer.stake(address(auraBal), auraBal.balanceOf(controller));
    auraBalFarmer.stake(address(bal), bal.balanceOf(controller));
    vm.stopPrank();
  }

  function _defaultBehavior(uint256 time) internal {
    _assertNoPendingRewards(); // TODO not that useful anymore

    vm.warp(block.timestamp + time);
    auraBalFarmer.harvest();

    // TODO test numbers but should be fine
  }

  function testDefaultBehavior(uint256 time) public {
    vm.assume(time < 10_000 days);
    _defaultBehavior(time);
  }

  function testWhenNotPaused() public {
    vm.prank(admin);
    auraBalFarmer.pause();
    vm.expectRevert("Pausable: paused");
    auraBalFarmer.harvest();
  }
}
