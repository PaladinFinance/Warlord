// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./BaseLockerTest.sol";

contract Shutdown is BaseLockerTest {
  function testDefaultBehavior() public {
    assertFalse(dummyLocker.isShutdown());

    vm.startPrank(admin);
    dummyLocker.pause();
    dummyLocker.shutdown();
    vm.stopPrank();

    assertTrue(dummyLocker.isShutdown());
  }

  function testOnlyOwner() public {
    vm.prank(admin);
    dummyLocker.pause();
    vm.expectRevert("Ownable: caller is not the owner");
    dummyLocker.shutdown();
  }

  function testWhenPaused() public {
    vm.prank(admin);

    vm.expectRevert("Pausable: not paused");
    dummyLocker.shutdown();
  }
}
