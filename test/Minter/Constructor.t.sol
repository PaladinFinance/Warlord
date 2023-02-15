// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./MinterTest.sol";

contract Constructor is MinterTest {
  function testDefaultBehavior() public {
    assertEq(minter.warToken(), address(war));
    assertEq(minter.mintRatio(), address(mintRatio));
  }

  function testCantConstructWithZeroAddressWar(address randomAddress) public {
    vm.assume(randomAddress != zero);
    vm.expectRevert(Errors.ZeroAddress.selector);
    new WarMinter(zero, randomAddress);
  }

  function testCantConstructWithZeroAddressRatio(address randomAddress) public {
    vm.assume(randomAddress != zero);
    vm.expectRevert(Errors.ZeroAddress.selector);
    new WarMinter(randomAddress, zero);
  }
}
