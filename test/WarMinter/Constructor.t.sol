// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarMinterTest.sol";

contract Constructor is WarMinterTest {
  function testCantConstructWithZeroAddress() public {
    vm.expectRevert(ZeroAddress.selector);
    new WarMinter(address(0));
  }
}
