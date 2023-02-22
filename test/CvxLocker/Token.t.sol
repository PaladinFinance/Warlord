// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./CvxLockerTest.sol";

contract Token is CvxLockerTest {
  function testDefaultBehavior() public {
    assertEq(locker.token(), address(cvx));
  }
}
