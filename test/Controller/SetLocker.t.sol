// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./ControllerTest.sol";

contract SetLocker is ControllerTest {
  function testNewLocker(address token, address locker) public {
    vm.assume(token != zero);
    vm.assume(locker != zero);

    vm.expectEmit(true, false, false, true);
    emit SetLocker(token, locker);

    vm.prank(admin);
    controller.setLocker(token, locker);

    assertEq(controller.tokenLockers(token), locker, "locker for that token should be the assigned one");
    assertEq(controller.lockers(0), locker, "locker should be added to the locker list");
    assertEq(
      expose(controller).getLockersLength(),
      1,
      "the lenght of the array with locker should be one after adding new token"
    );
  }

  struct TokenWithLocker {
    address token;
    address locker;
  }

  function generateTokenWithLocker(uint256 seed1, uint256 seed2, uint256 size)
    public
    pure
    returns (TokenWithLocker[] memory dummyLocks)
  {
    vm.assume(seed1 < 1e70);
    vm.assume(seed2 < 1e70);
    address[] memory tokens = generateAddressArrayFromHash(seed1, size);
    address[] memory lockers = generateAddressArrayFromHash(seed2, size);
    dummyLocks = new TokenWithLocker[](size);
    for (uint256 i; i < size; ++i) {
      dummyLocks[i].token = tokens[i];
      dummyLocks[i].locker = lockers[i];
    }
  }

  function testNewLockerWithReplacement(uint256 seed1, uint256 seed2, uint256 size, address newLocker) public {
    vm.assume(newLocker != zero);
    vm.assume(size <= 100);

    TokenWithLocker[] memory initialLockers = generateTokenWithLocker(seed1, seed2, size);

    vm.startPrank(admin);
    for (uint256 i; i < initialLockers.length; ++i) {
      vm.assume(newLocker != initialLockers[i].locker);
      if (initialLockers[i].token == zero || initialLockers[i].locker == zero) continue;
      controller.setLocker(initialLockers[i].token, initialLockers[i].locker);
    }
    vm.stopPrank();

    uint256 assignedLength = expose(controller).getLockersLength();
    vm.assume(assignedLength > 0);

    address[] memory tokens = new address[](initialLockers.length);
    for (uint256 i; i < assignedLength; ++i) {
      tokens[i] = initialLockers[i].token;
    }

    uint256 indexOldLocker = uint256(uint160(newLocker)) % assignedLength;
    address tokenWithNewLocker = tokens[indexOldLocker];

    vm.prank(admin);
    controller.setLocker(tokenWithNewLocker, newLocker);
    uint256 newLockerIndex = expose(controller).getLockersLength();

    assertEq(controller.lockers(newLockerIndex - 1), newLocker, "the new locker should be at the end of the array");
    assertEq(newLockerIndex, assignedLength, "the length of the array shouldn't change");
    assertEq(
      controller.tokenLockers(tokenWithNewLocker), newLocker, "new locker for that token should be the assigned one"
    );
  }

  function testOnlyOwner(address token, address locker) public {
    vm.assume(locker != zero);
    vm.assume(token != zero);

    vm.expectRevert("Ownable: caller is not the owner");
    controller.setLocker(token, locker);
  }

  function testZeroAddressToken(address locker) public {
    vm.assume(locker != zero);

    vm.expectRevert(Errors.ZeroAddress.selector);

    vm.prank(admin);
    controller.setLocker(zero, locker);
  }

  function testZeroAddressLocker(address token) public {
    vm.assume(token != zero);

    vm.expectRevert(Errors.ZeroAddress.selector);

    vm.prank(admin);
    controller.setLocker(token, zero);
  }

  function testListedLocker(address token, address locker) public {
    vm.assume(token != zero);
    vm.assume(locker != zero);

    vm.prank(admin);
    controller.setFarmer(token, locker);

    vm.expectRevert(Errors.ListedFarmer.selector);

    vm.prank(admin);
    controller.setLocker(token, locker);
  }
}
