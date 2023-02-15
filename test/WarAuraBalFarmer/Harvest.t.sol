// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarAuraBalFarmerTest.sol";

contract Harvest is WarAuraBalFarmerTest {
  function setUp() public override {
    WarAuraBalFarmerTest.setUp();
    vm.startPrank(controller);
    warAuraBalFarmer.stake(address(auraBal), auraBal.balanceOf(controller));
    warAuraBalFarmer.stake(address(bal), bal.balanceOf(controller));
    vm.stopPrank();
  }

  function _defaultBehavior(uint256 time) internal {
    _assertNoPendingRewards(); // TODO not that useful anymore

    vm.warp(block.timestamp + time);
    warAuraBalFarmer.harvest();

    // TODO test numbers but should be fine
  }

  function testDefaultBehavior(uint256 time) public {
    vm.assume(time < 10_000 days);
    _defaultBehavior(time);
  }

  function testWhenNotPaused() public {
    vm.prank(admin);
    warAuraBalFarmer.pause();
    vm.expectRevert("Pausable: paused");
    warAuraBalFarmer.harvest();
  }
}
