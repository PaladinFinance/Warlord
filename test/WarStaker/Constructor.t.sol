// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarStakerTest.sol";

contract Constructor is WarStakerTest {
  function testCorrectlyConstructed() public {
    assertEq(staker.owner(), admin); // TODO do the same for all contracts using owner
    assertEq(staker.warToken(), address(war));
  }

  function testCantUseZeroAddress() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    new WarStaker(zero);
  }
}
