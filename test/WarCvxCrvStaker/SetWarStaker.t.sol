// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarCvxCrvStakerTest.sol";

contract SetWarStaker is WarCvxCrvStakerTest {
  function testDefaultBehavior(address newWarStaker) public {
    vm.assume(newWarStaker != zero);
    vm.prank(admin);
    cvxCrvStaker.setWarStaker(newWarStaker);
    assertEq(cvxCrvStaker.warStaker(), newWarStaker);
  }

  function testRevertWithZeroAddress() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    vm.prank(admin);
    cvxCrvStaker.setWarStaker(zero);
  }

  function testOnlyOwner() public {
    vm.expectRevert("Ownable: caller is not the owner");
    cvxCrvStaker.setWarStaker(alice);
  }
}