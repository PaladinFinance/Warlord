// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarCvxCrvStakerTest.sol";

contract Pause is WarCvxCrvStakerTest {
  function testDefaultBehavior() public {
    assertEq(warCvxCrvStaker.paused(), false);
    vm.prank(admin);
    warCvxCrvStaker.pause();
    assertEq(warCvxCrvStaker.paused(), true);
  }

  function testOnlyOwner() public {
    vm.prank(alice);
    vm.expectRevert("Ownable: caller is not the owner");
    warCvxCrvStaker.pause();
  }
}
