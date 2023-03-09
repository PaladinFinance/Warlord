// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./MinterTest.sol";

contract Constructor is MinterTest {
  function testDefaultBehavior() public {
    assertEq(address(minter.war()), address(war));
    assertEq(address(minter.mintRatio()), address(mintRatio));
  }

  function testZeroAddressWar(address randomMintRatio) public {
    vm.assume(randomMintRatio != zero);

    vm.expectRevert(Errors.ZeroAddress.selector);
    new WarMinter(zero, randomMintRatio);
  }

  function testZeroAddressRatio(address randomWarToken) public {
    vm.assume(randomWarToken != zero);

    vm.expectRevert(Errors.ZeroAddress.selector);
    new WarMinter(randomWarToken, zero);
  }
}
