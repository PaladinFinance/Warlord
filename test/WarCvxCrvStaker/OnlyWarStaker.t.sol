// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarCvxCrvStakerTest.sol";

contract OnlyWarStaker is WarCvxCrvStakerTest {
  function testDefaultBehavior() public {
    // Checking all the functions that require the WarStaker to be calling them
    vm.expectRevert(Errors.CallerNotAllowed.selector);
    vm.prank(alice);
    cvxCrvStaker.sendTokens(address(crv), 100e18);
  }
}
