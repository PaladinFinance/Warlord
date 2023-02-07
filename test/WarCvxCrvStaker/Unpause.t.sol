// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarCvxCrvStakerTest.sol";

contract Unpause is WarCvxCrvStakerTest {
  function setUp() public override {
    WarCvxCrvStakerTest.setUp();
    vm.prank(admin);
    warCvxCrvStaker.pause();
  }

  function testDefaultBehavior() public {
    assertEq(warCvxCrvStaker.paused(), true);
    vm.prank(admin);
    warCvxCrvStaker.unpause();
    assertEq(warCvxCrvStaker.paused(), false);
  }

  function testOnlyOwner() public {
    vm.prank(alice);
    vm.expectRevert("Ownable: caller is not the owner");
    warCvxCrvStaker.unpause();
  }
}
