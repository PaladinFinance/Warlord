// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./BaseLockerTest.sol";

contract Harvest is BaseLockerTest {
  function testWhenPaused() public {
    vm.expectRevert("Pausable: not paused");
    vm.prank(admin);
    dummyLocker.migrate(makeAddr("randomReceiver"));
  }

  function testOnlyOwner() public {
    vm.prank(admin);
    dummyLocker.pause();
    vm.expectRevert("Ownable: caller is not the owner");
    dummyLocker.migrate(makeAddr("randomReceiver"));
  }

  function testZeroAddress() public {
    vm.prank(admin);
    dummyLocker.pause();
    vm.expectRevert(Errors.ZeroAddress.selector);
    vm.prank(admin);
    dummyLocker.migrate(zero);
  }

  // TODO test shutdown
}
