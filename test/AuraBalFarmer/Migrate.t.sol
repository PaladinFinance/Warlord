// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarAuraBalFarmerTest.sol";

contract Migrate is WarAuraBalFarmerTest {
/*
  address migration = makeAddr("migration");

  function setUp() public override {
    WarAuraBalStakerTest.setUp();
    vm.startPrank(controller);
    warCvxCrvFarmer.stake(address(cvxCrv), cvxCrv.balanceOf(controller));
    warCvxCrvFarmer.stake(address(crv), crv.balanceOf(controller));
    vm.stopPrank();
    vm.warp(block.timestamp + 100 days);
    vm.prank(admin);
    warCvxCrvFarmer.pause();
  }

  function testDefaultBehavior() public {
    (uint256 crvRewards, uint256 cvxRewards, uint256 threeCrvRewards) = _getRewards();

    uint256 stakedBalance = convexCvxCrvStaker.balanceOf(address(warCvxCrvFarmer));
    assertEq(cvxCrv.balanceOf(migration), 0);

    vm.prank(admin);
    warCvxCrvFarmer.migrate(migration);

    assertEq(cvxCrv.balanceOf(migration), stakedBalance);

    assertEq(crv.balanceOf(controller), crvRewards);
    assertEq(cvx.balanceOf(controller), cvxRewards);
    assertEq(threeCrv.balanceOf(controller), threeCrvRewards);

    _assertNoPendingRewards();
  }

  function testWhenIsPaused() public {
    vm.startPrank(admin);
    warCvxCrvFarmer.unpause();
    vm.expectRevert("Pausable: not paused");
    warCvxCrvFarmer.migrate(migration);
    vm.stopPrank();
  }

  function testOnlyOwner() public {
    vm.expectRevert("Ownable: caller is not the owner");
    vm.prank(alice);
    warCvxCrvFarmer.migrate(alice);
  }

  function testZeroAddress() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    vm.prank(admin);
    warCvxCrvFarmer.migrate(zero);
  }*/
}
