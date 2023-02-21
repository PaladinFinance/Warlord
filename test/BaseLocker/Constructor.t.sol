// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./BaseLockerTest.sol";

contract Constructor is BaseLockerTest {
  function testDefaultBehavior() public {
    assertEq(dummyLocker.controller(), controller);
    assertEq(dummyLocker.redeemModule(), address(redeemModule));
    assertEq(dummyLocker.warMinter(), address(minter));
    assertEq(dummyLocker.delegatee(), delegate);
    assertFalse(dummyLocker.isShutdown());
  }

  function testZeroAddressController() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    new WarDummyLocker(zero, address(redeemModule), address(minter), delegate);
  }

  function testZeroAddressRedeemModule() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    new WarDummyLocker(controller, zero, address(minter), delegate);
  }

  function testZeroAddressMinter() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    new WarDummyLocker(controller, address(redeemModule), zero, delegate);
  }

  function testZeroAddresses() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    new WarDummyLocker(controller, zero, zero, delegate);
    vm.expectRevert(Errors.ZeroAddress.selector);
    new WarDummyLocker(zero, address(redeemModule), zero, delegate);
    vm.expectRevert(Errors.ZeroAddress.selector);
    new WarDummyLocker(zero, zero, address(minter), delegate);
    vm.expectRevert(Errors.ZeroAddress.selector);
    new WarDummyLocker(zero, zero, zero, delegate);
  }
}
