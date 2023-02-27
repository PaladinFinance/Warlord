// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./BaseFarmerTest.sol";

contract SetWarStaker is BaseFarmerTest {
  function testDefaultBehavior(address newWarStaker) public {
    vm.assume(newWarStaker != zero && newWarStaker != address(warStaker));
    vm.prank(admin);
    dummyFarmer.setWarStaker(newWarStaker);
    assertEq(dummyFarmer.warStaker(), newWarStaker);
  }

  function testRevertWithZeroAddress() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    vm.prank(admin);
    dummyFarmer.setWarStaker(zero);
  }

  function testOnlyOwner() public {
    vm.expectRevert("Ownable: caller is not the owner");
    dummyFarmer.setWarStaker(alice);
  }

  function testSameValue() public {
    vm.expectRevert(Errors.AlreadySet.selector);
    vm.prank(admin);
    dummyFarmer.setWarStaker(address(warStaker));
  }
}
