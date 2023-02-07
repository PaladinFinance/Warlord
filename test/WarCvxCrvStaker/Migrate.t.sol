// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarCvxCrvStakerTest.sol";

contract Migrate is WarCvxCrvStakerTest {
  address migration = makeAddr("migration");

  function setUp() public override {
    WarCvxCrvStakerTest.setUp();
    vm.startPrank(controller);
    warCvxCrvStaker.stake(address(cvxCrv), cvxCrv.balanceOf(controller));
    warCvxCrvStaker.stake(address(crv), crv.balanceOf(controller));
    vm.stopPrank();
    vm.warp(block.timestamp + 100 days);
    vm.prank(admin);
    warCvxCrvStaker.pause();
  }

  function testDefaultBehavior() public {
    (uint256 crvRewards, uint256 cvxRewards, uint256 threeCrvRewards) = _getRewards();

    uint256 stakedBalance = convexCvxCrvStaker.balanceOf(address(warCvxCrvStaker));
    assertEq(cvxCrv.balanceOf(migration), 0);

    vm.prank(admin);
    warCvxCrvStaker.migrate(migration);

    assertEq(cvxCrv.balanceOf(migration), stakedBalance);

    assertEq(crv.balanceOf(controller), crvRewards);
    assertEq(cvx.balanceOf(controller), cvxRewards);
    assertEq(threeCrv.balanceOf(controller), threeCrvRewards);
    
    _assertNoPendingRewards();
  }

  function testWhenIsPaused() public {
    vm.startPrank(admin);
    warCvxCrvStaker.unpause();
    vm.expectRevert("Pausable: not paused");
    warCvxCrvStaker.migrate(migration);
    vm.stopPrank();
  }

  function testOnlyOwner() public {
    vm.expectRevert("Ownable: caller is not the owner");
    vm.prank(alice);
    warCvxCrvStaker.migrate(alice);
  }

  function testZeroAddress() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    vm.prank(admin);
    warCvxCrvStaker.migrate(zero);
  }
}
