// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./RedeemerTest.sol";

contract SetLocker is RedeemerTest {
  function testDefaultBehavior(address token) public {
    vm.assume(token != zero);

    DummyLocker locker = new DummyLocker(token);

    vm.expectEmit(true, false, false, true);
    emit SetWarLocker(token, address(locker));

    vm.prank(admin);
    redeemer.setLocker(token, address(locker));

    assertEq(redeemer.lockers(token), address(locker), "the locker of the token should be assigned correctly");
    assertEq(redeemer.lockerTokens(address(locker)), token, "the token of the locker should be assigned correctly");
  }
  function testZeroAddressToken(address locker) public {
    vm.assume(locker != zero);

    vm.expectRevert(Errors.ZeroAddress.selector);

    vm.prank(admin);
    redeemer.setLocker(zero, locker);
  }
  function testZeroAddressLocker(address token) public {
    vm.assume(token != zero);

    vm.expectRevert(Errors.ZeroAddress.selector);

    vm.prank(admin);
    redeemer.setLocker(token, zero);
  }
  function testMismatchingLocker(address token, address notToken) public {
    vm.assume(token != zero && notToken != zero && token != notToken);
    DummyLocker locker = new DummyLocker(notToken);

    vm.expectRevert(abi.encodeWithSelector(Errors.MismatchingLocker.selector, notToken, token));

    vm.prank(admin);
    redeemer.setLocker(token, address(locker));
  }
  function testOnlyOwner(address token, address locker) public {
    vm.expectRevert("Ownable: caller is not the owner");
    redeemer.setLocker(token, locker);
  }
}