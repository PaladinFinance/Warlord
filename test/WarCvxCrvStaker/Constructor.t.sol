// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarCvxCrvStakerTest.sol";

contract Constructor is WarCvxCrvStakerTest {
  function testDefaultBehavior() public {
    // Tested in the setUp function
  }

  function testZeroControllerReverts() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    new WarCvxCrvStaker(zero, alice);
  }

  function testZeroWarStakerReverts() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    new WarCvxCrvStaker(bob, zero);
  }

  function testZeroAddresses() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    new WarCvxCrvStaker(zero, zero);
  }
}
