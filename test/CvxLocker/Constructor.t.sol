// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./CvxLockerTest.sol";

contract Constructor is CvxLockerTest {
  function testDefaultBehavior() public {
    assertEq(locker.token(), address(cvx)); // TODO clean this up
    assertEq(locker.controller(), controller);
    assertEq(address(locker.redeemModule()), address(redeemModule));
    assertEq(registry.delegation(address(locker), "cvx.eth"), delegatee);
    assertEq(locker.delegatee(), delegatee);
  }

  function testZeroAddressController() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    new WarCvxLocker(zero, address(redeemModule), address(minter), delegatee);
  }

  function testZeroAddressRedeemModule() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    new WarCvxLocker(controller, zero, address(minter), delegatee);
  }

  function testZeroAddressMinter() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    new WarCvxLocker(controller, address(redeemModule), zero, delegatee);
  }

  function testZeroAddresses() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    new WarCvxLocker(controller, zero, zero, delegatee);
    vm.expectRevert(Errors.ZeroAddress.selector);
    new WarCvxLocker(zero, address(redeemModule), zero, delegatee);
    vm.expectRevert(Errors.ZeroAddress.selector);
    new WarCvxLocker(zero, zero, address(minter), delegatee);
    vm.expectRevert(Errors.ZeroAddress.selector);
    new WarCvxLocker(zero, zero, zero, delegatee);
  }
}
