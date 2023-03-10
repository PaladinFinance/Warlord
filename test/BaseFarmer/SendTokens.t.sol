// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./BaseFarmerTest.sol";

contract SendTokens is BaseFarmerTest {
  function testZeroAmount(address receiver) public {
    vm.assume(receiver != zero);

    vm.expectRevert(Errors.ZeroValue.selector);

    vm.prank(address(warStaker));
    dummyFarmer.sendTokens(receiver, 0);
  }

  function testZeroAddress(uint256 amount) public {
    vm.assume(amount != 0);

    vm.expectRevert(Errors.ZeroAddress.selector);

    vm.prank(address(warStaker));
    dummyFarmer.sendTokens(zero, amount);
  }

  function testOnlyWarStaker(address receiver, uint256 amount) public {
    vm.assume(receiver != zero);
    vm.assume(amount != 0);

    vm.expectRevert(Errors.CallerNotAllowed.selector);
    dummyFarmer.sendTokens(receiver, amount);
  }

  function testNonReentrant(address receiver, uint256 amount) public enableReentrancy {
    vm.assume(receiver != zero);
    vm.assume(amount != 0);

    vm.expectRevert("REENTRANCY");

    vm.prank(address(warStaker));
    dummyFarmer.sendTokens(receiver, amount);
  }
}
