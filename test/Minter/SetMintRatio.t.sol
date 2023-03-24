// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./MinterTest.sol";

contract SetMintRatio is MinterTest {
  function testDefaultBehavior(address _ratios) public {
    vm.assume(_ratios != zero);
    vm.prank(admin);
    minter.setMintRatio(_ratios);
  }

  function testOnlyOwner(address _ratios) public {
    vm.prank(bob);
    vm.expectRevert("Ownable: caller is not the owner");
    minter.setMintRatio(_ratios);
  }

  function testZeroAddress() public {
    vm.prank(admin);
    vm.expectRevert(Errors.ZeroAddress.selector);
    minter.setMintRatio(zero);
  }
}
