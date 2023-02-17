// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./AuraBalFarmerTest.sol";

contract Migrate is AuraBalFarmerTest {
  address migration = makeAddr("migration");

  function setUp() public override {
    AuraBalFarmerTest.setUp();
    vm.startPrank(controller);
    auraBalFarmer.stake(address(auraBal), auraBal.balanceOf(controller));
    auraBalFarmer.stake(address(bal), bal.balanceOf(controller));
    vm.stopPrank();
    vm.warp(block.timestamp + 100 days);

    vm.prank(admin);
    auraBalFarmer.pause();
  }

  function testDefaultBehavior() public {
    (uint256 balRewards, uint256 auraRewards, uint256 bbAUsdRewards) = _getRewards();

    uint256 stakedBalance = auraBalStaker.balanceOf(address(auraBalFarmer));
    assertEq(auraBal.balanceOf(migration), 0);

    vm.prank(admin);
    auraBalFarmer.migrate(migration);

    assertEq(auraBal.balanceOf(migration), stakedBalance);

    assertEq(bal.balanceOf(controller), balRewards);
    assertEq(aura.balanceOf(controller), auraRewards);
    assertEq(bbAUsd.balanceOf(controller), bbAUsdRewards);

    _assertNoPendingRewards();
  }

  function testWhenIsPaused() public {
    vm.startPrank(admin);
    auraBalFarmer.unpause();
    vm.expectRevert("Pausable: not paused");
    auraBalFarmer.migrate(migration);
    vm.stopPrank();
  }

  function testOnlyOwner() public {
    vm.expectRevert("Ownable: caller is not the owner");
    vm.prank(alice);
    auraBalFarmer.migrate(alice);
  }

  function testZeroAddress() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    vm.prank(admin);
    auraBalFarmer.migrate(zero);
  }
}
