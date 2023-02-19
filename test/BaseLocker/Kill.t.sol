// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./BaseLockerTest.sol";

contract Kill is BaseLockerTest {
  function testDefaultBehavior() public {
    assertEq(dummyLocker.killed(), false);

    vm.startPrank(admin);
    dummyLocker.pause();
    dummyLocker.kill();
    vm.stopPrank();

    assertEq(dummyLocker.killed(), true);
  }

  function testOnlyOwner() public {
    vm.prank(admin);
    dummyLocker.pause();
    vm.expectRevert("Ownable: caller is not the owner");
    dummyLocker.kill();
  }

  function testWhenPaused() public {
    vm.prank(admin);

    vm.expectRevert("Pausable: not paused");
    dummyLocker.kill();
  }
}
