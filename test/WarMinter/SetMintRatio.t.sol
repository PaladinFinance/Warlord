// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarMinterTest.sol";

contract SetMintRatio is WarMinterTest {
  function testSetter() public {
    vm.prank(admin);
    minter.setMintRatio(address(42));
  }

  function testOnlyAdminCanCall() public {
    vm.prank(bob);
    vm.expectRevert("Ownable: caller is not the owner");
    minter.setMintRatio(address(42));
  }

  function testCantUseZeroAddress() public {
    vm.prank(admin);
    vm.expectRevert(Errors.ZeroAddress.selector);
    minter.setMintRatio(zero);
  }
}
