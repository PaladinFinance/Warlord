// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./BaseLockerTest.sol";

contract Lock is BaseLockerTest {
  function testOnlyWarMinter() public {
    vm.expectRevert(Errors.CallerNotAllowed.selector);
    dummyLocker.lock(423_759_020);
  }

  function testWhenNotPaused() public {
    vm.prank(admin);
    dummyLocker.pause();
    vm.expectRevert("Pausable: paused");
    vm.prank(address(minter));
    dummyLocker.lock(54_734_950);
  }

  function testZeroAmount() public {
    vm.expectRevert(Errors.ZeroValue.selector);
    vm.prank(address(minter));
    dummyLocker.lock(0);
  }
}
