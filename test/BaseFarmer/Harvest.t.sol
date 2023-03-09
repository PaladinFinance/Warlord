// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./BaseFarmerTest.sol";

contract Harvest is BaseFarmerTest {
  function testWhenNotPaused() public {
    vm.prank(admin);
    dummyFarmer.pause();

    vm.expectRevert("Pausable: paused");
    dummyFarmer.harvest();
  }

  function testNonReentrant() public {
    // TODO #4
  }
}
