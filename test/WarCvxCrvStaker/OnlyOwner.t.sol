// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarCvxCrvStakerTest.sol";

contract OnlyOwner is WarCvxCrvStakerTest {
  function testDefaultBehavior() public {
    // Checking all the functions that require the owner to be calling them
    vm.startPrank(alice);
    vm.expectRevert("Ownable: caller is not the owner");
    warCvxCrvStaker.setRewardWeight(5);
    vm.expectRevert("Ownable: caller is not the owner");
    warCvxCrvStaker.setWarStaker(address(5));
    vm.expectRevert("Ownable: caller is not the owner");
    warCvxCrvStaker.setController(address(5));
    vm.expectRevert("Ownable: caller is not the owner");
    warCvxCrvStaker.migrate(address(5));
    vm.stopPrank();
  }
}
