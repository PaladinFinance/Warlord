// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./MinterTest.sol";

contract Constructor is MinterTest {
  function testDefaultBehavior() public {
    assertEq(minter.warToken(), address(war));
    assertEq(minter.mintRatio(), address(mintRatio));
  }

  function testCantConstructWithZeroAddressWar(address mintRatio) public {
    vm.assume(mintRatio != zero);
    vm.expectRevert(Errors.ZeroAddress.selector);
    new WarMinter(zero, mintRatio);
  }

  function testCantConstructWithZeroAddressRatio(address mintRatio) public {
    vm.assume(mintRatio != zero);
    vm.expectRevert(Errors.ZeroAddress.selector);
    new WarMinter(mintRatio, zero);
  }
}
