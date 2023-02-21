// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./BaseLockerTest.sol";

contract ProcessUnlock is BaseLockerTest {
  function testWhenNotPaused() public {
    vm.prank(admin);
    dummyLocker.pause();
    vm.expectRevert("Pausable: paused");
    dummyLocker.processUnlock();
  }
}
