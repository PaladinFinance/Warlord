// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./BaseFarmerTest.sol";

contract GetCurrentIndex is BaseFarmerTest {
  function testDefaultBehvior() public {
    assertEq(dummyFarmer.getCurrentIndex(), 0);
  }
}
