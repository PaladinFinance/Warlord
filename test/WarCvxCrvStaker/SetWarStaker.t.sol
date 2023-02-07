// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarCvxCrvStakerTest.sol";

contract SetWarStaker is WarCvxCrvStakerTest {
  function testDefaultBehavior(address newWarStaker) public {
    vm.assume(newWarStaker != zero && newWarStaker != address(warStaker));
    vm.prank(admin);
    warCvxCrvStaker.setWarStaker(newWarStaker);
    assertEq(warCvxCrvStaker.warStaker(), newWarStaker);
  }

  function testRevertWithZeroAddress() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    vm.prank(admin);
    warCvxCrvStaker.setWarStaker(zero);
  }

  function testOnlyOwner() public {
    vm.expectRevert("Ownable: caller is not the owner");
    warCvxCrvStaker.setWarStaker(alice);
  }

  function testSameValue() public {
    vm.expectRevert(Errors.AlreadySet.selector);
    vm.prank(admin);
    warCvxCrvStaker.setWarStaker(address(warStaker));
  }
}
