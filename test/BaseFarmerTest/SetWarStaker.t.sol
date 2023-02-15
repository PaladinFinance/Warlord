// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarBaseFarmerTest.sol";

contract SetWarStaker is WarBaseFarmerTest {
  function testDefaultBehavior(address newWarStaker) public {
    vm.assume(newWarStaker != zero && newWarStaker != address(warStaker));
    vm.prank(admin);
    warMockFarmer.setWarStaker(newWarStaker);
    assertEq(warMockFarmer.warStaker(), newWarStaker);
  }

  function testRevertWithZeroAddress() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    vm.prank(admin);
    warMockFarmer.setWarStaker(zero);
  }

  function testOnlyOwner() public {
    vm.expectRevert("Ownable: caller is not the owner");
    warMockFarmer.setWarStaker(alice);
  }

  function testSameValue() public {
    vm.expectRevert(Errors.AlreadySet.selector);
    vm.prank(admin);
    warMockFarmer.setWarStaker(address(warStaker));
  }
}
