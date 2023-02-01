// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarMinterTest.sol";

contract Constructor is WarMinterTest {
  function testConstructorWorks() public {
    new WarMinter(address(1), address(2));
  }

  function testCantConstructWithZeroAddressWar() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    new WarMinter(address(0), address(2));
  }

  function testCantConstructWithZeroAddressRatio() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    new WarMinter(address(1), address(0));
  }
}
