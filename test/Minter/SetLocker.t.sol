// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./MinterTest.sol";

contract SetLocker is MinterTest {
  function testDefaultBehavior(uint256 supply) public {
    vm.assume(supply > 1e20 && supply < 1e40);
    address token = makeAddr("token");
    DummyLocker locker = new DummyLocker(token); // TODO check also for real lockers when they're ready
    vm.prank(admin);
    minter.setLocker(token, address(locker));
    assertEq(minter.lockers(token), address(locker));
  }

  function testZeroAddressToken(address locker) public {
    vm.assume(locker > zero);
    vm.prank(admin);
    vm.expectRevert(Errors.ZeroAddress.selector);
    minter.setLocker(zero, locker);
  }

  function testZeroAddressLocker(address locker) public {
    vm.assume(locker > zero);
    vm.prank(admin);
    vm.expectRevert(Errors.ZeroAddress.selector);
    minter.setLocker(locker, zero);
  }

  function testZeroAddresses() public {
    vm.prank(admin);
    vm.expectRevert(Errors.ZeroAddress.selector);
    minter.setLocker(zero, zero);
  }

  function testOnlyAdminCanCall() public {
    vm.prank(alice);
    vm.expectRevert("Ownable: caller is not the owner");
    minter.setLocker(address(cvx), address(cvxLocker));
  }

  function testCantSetMismatchingLocker(address notToken) public {
    address correctToken = makeAddr("correctToken");
    DummyLocker newLocker = new DummyLocker(correctToken);
    vm.assume(notToken != zero && notToken != correctToken && notToken != address(newLocker));
    vm.expectRevert(abi.encodeWithSelector(Errors.MismatchingLocker.selector, newLocker.token(), notToken));
    vm.prank(admin);
    minter.setLocker(notToken, address(newLocker));
  }
}
