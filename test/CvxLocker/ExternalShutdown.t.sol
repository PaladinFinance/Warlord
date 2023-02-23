// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./CvxLockerTest.sol";

contract ExternalShutdown is CvxLockerTest {
  function testDefaultBehavior() public {
    vm.prank(vlCvx.owner());
    vlCvx.shutdown();

    vm.startPrank(admin);
    locker.pause();
    // No expired locks means that the check for shutdown passed succesfully
    vm.expectRevert("no exp locks");
    locker.migrate(alice);
    vm.stopPrank();
  }
}
