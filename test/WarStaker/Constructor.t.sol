// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarStakerTest.sol";

contract Constructor is WarStakerTest {
  function testDefaultBehavior() public {
    assertEq(staker.owner(), admin);
    assertEq(staker.warToken(), address(war));
  }

  function testCantUseZeroAddress() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    new WarStaker(zero);
  }
}
