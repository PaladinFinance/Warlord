// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarMinterTest.sol";

contract SetMintRatio is WarMinterTest {
  function testDefaultBehavior(address _mintRatio) public {
    vm.assume(_mintRatio != zero);
    vm.prank(admin);
    minter.setMintRatio(_mintRatio);
  }

  function testOnlyAdminCanCall(address _mintRatio) public {
    vm.prank(bob);
    vm.expectRevert("Ownable: caller is not the owner");
    minter.setMintRatio(_mintRatio);
  }

  function testCantUseZeroAddress() public {
    vm.prank(admin);
    vm.expectRevert(Errors.ZeroAddress.selector);
    minter.setMintRatio(zero);
  }
}
