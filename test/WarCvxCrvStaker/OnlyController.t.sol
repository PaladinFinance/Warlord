// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarCvxCrvStakerTest.sol";

contract OnlyController is WarCvxCrvStakerTest {
  function testDefaultBehavior() public {
    // Checking all the functions that require the controller to be calling them
    vm.expectRevert(Errors.CallerNotAllowed.selector);
    vm.prank(alice);
    cvxCrvStaker.stake(address(crv), 100e18);
  }
}
