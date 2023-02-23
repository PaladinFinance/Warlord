// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./CvxLockerTest.sol";

contract Constructor is CvxLockerTest {
  function testDefaultBehavior() public {
    assertEq(registry.delegation(address(locker), "cvx.eth"), delegatee);
  }
}
