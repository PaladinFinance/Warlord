// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./BaseLockerTest.sol";

contract Harvest is BaseLockerTest {
  address randomReceiver = makeAddr("randomReceiver");

  function testWhenPaused() public {
    vm.expectRevert("Pausable: not paused");
    vm.prank(admin);
    dummyLocker.migrate(randomReceiver);
  }

  function testOnlyOwner() public {
    vm.prank(admin);
    dummyLocker.pause();
    vm.expectRevert("Ownable: caller is not the owner");
    dummyLocker.migrate(randomReceiver);
  }

  function testZeroAddress() public {
    vm.prank(admin);
    dummyLocker.pause();
    vm.expectRevert(Errors.ZeroAddress.selector);
    vm.prank(admin);
    dummyLocker.migrate(zero);
  }

  function testLockerStillAlive() public {
    vm.startPrank(admin);
    dummyLocker.pause();
    vm.expectRevert(Errors.LockerStillAlive.selector);
    dummyLocker.migrate(randomReceiver);
    vm.stopPrank();
  }

  function testExternalShutdown() public {
    dummyLocker.activateExternalShutdown();
    vm.startPrank(admin);
    dummyLocker.pause();
    dummyLocker.migrate(randomReceiver);
    vm.stopPrank();
  }

  function testInternalShutdown() public {
    vm.startPrank(admin);
    dummyLocker.pause();
    dummyLocker.shutdown();
    dummyLocker.migrate(randomReceiver);
    vm.stopPrank();
  }

  function testInternalAndExternalShutdown() public {
    dummyLocker.activateExternalShutdown();
    vm.startPrank(admin);
    dummyLocker.pause();
    dummyLocker.shutdown();
    dummyLocker.migrate(randomReceiver);
    vm.stopPrank();
  }
}
