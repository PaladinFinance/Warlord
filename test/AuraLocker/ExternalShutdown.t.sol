// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./AuraLockerTest.sol";

contract ExternalShutdown is AuraLockerTest {
  function testDefaultBehavior() public {
    vm.prank(vlAura.owner());
    vlAura.shutdown();

    vm.startPrank(admin);
    locker.pause();
    // No locks means that the check for shutdown passed succesfully
    vm.expectRevert("no locks");
    locker.migrate(alice);
    vm.stopPrank();
  }
}
