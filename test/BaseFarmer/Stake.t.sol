// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./BaseFarmerTest.sol";

contract Stake is BaseFarmerTest {
  function testDefaultBehavior(address token, uint256 amount) public {
    vm.assume(amount > 0);

    vm.expectEmit(false, false, false, true);
    emit Staked(amount);

    vm.prank(controller);
    dummyFarmer.stake(token, amount);
  }

  function testOnlyController(address token) public {
    vm.expectRevert(Errors.CallerNotAllowed.selector);
    dummyFarmer.stake(token, 0);
  }

  function testWhenNotPaused(address token, uint256 amount) public {
    vm.prank(admin);
    dummyFarmer.pause();

    vm.expectRevert("Pausable: paused");

    vm.prank(controller);
    dummyFarmer.stake(token, amount);
  }

  function testZeroValue(address token) public {
    vm.expectRevert(Errors.ZeroValue.selector);

    vm.prank(controller);
    dummyFarmer.stake(token, 0);
  }

  function testNonReentrant(address token, uint256 amount) public enableReentrancy {
    vm.assume(amount != 0);

    vm.expectRevert("REENTRANCY");

    vm.prank(controller);
    dummyFarmer.stake(token, amount);
  }
}
