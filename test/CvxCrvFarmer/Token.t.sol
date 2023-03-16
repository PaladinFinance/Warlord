// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./CvxCrvFarmerTest.sol";

contract Harvest is CvxCrvFarmerTest {
  function testDefaultBehavior() public {
    assertEq(cvxCrvFarmer.token(), address(cvxCrv), "the token should be auraBal");
  }
}
