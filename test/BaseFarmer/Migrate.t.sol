// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./BaseFarmerTest.sol";

contract Migrate is BaseFarmerTest {
  function setUp() public override {
    BaseFarmerTest.setUp();

    vm.prank(admin);
    dummyFarmer.pause();
  }

  function testWhenIsPaused(address migration) public {
    vm.assume(migration != zero);

    vm.startPrank(admin);
    dummyFarmer.unpause();

    vm.expectRevert("Pausable: not paused");
    dummyFarmer.migrate(migration);

    vm.stopPrank();
  }

  function testOnlyOwner(address migration) public {
    vm.assume(migration != zero);

    vm.expectRevert("Ownable: caller is not the owner");
    dummyFarmer.migrate(alice);
  }

  function testZeroAddress() public {
    vm.expectRevert(Errors.ZeroAddress.selector);

    vm.prank(admin);
    dummyFarmer.migrate(zero);
  }
}
