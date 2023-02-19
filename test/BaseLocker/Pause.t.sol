// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./BaseLockerTest.sol";

contract Pause is BaseLockerTest {
  function testDefaultBehavior() public {
    assertEq(dummyLocker.paused(), false);
    vm.prank(admin);
    dummyLocker.pause();
    assertEq(dummyLocker.paused(), true);
  }

  function testOnlyOwner() public {
    vm.prank(alice);
    vm.expectRevert("Ownable: caller is not the owner");
    dummyLocker.pause();
  }
}
