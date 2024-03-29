// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./BaseLockerTest.sol";

contract Unpause is BaseLockerTest {
  function setUp() public override {
    BaseLockerTest.setUp();
    vm.prank(admin);
    dummyLocker.pause();
  }

  function testDefaultBehavior() public {
    assertTrue(dummyLocker.paused());
    vm.prank(admin);
    dummyLocker.unpause();
    assertFalse(dummyLocker.paused());
  }

  function testOnlyOwner() public {
    vm.prank(alice);
    vm.expectRevert("Ownable: caller is not the owner");
    dummyLocker.unpause();
  }

  function testShutdown() public {
    vm.startPrank(admin);
    dummyLocker.shutdown();

    vm.expectRevert(Errors.LockerShutdown.selector);
    dummyLocker.unpause();

    vm.stopPrank();
  }
}
