// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./AuraBalFarmerTest.sol";

contract Harvest is AuraBalFarmerTest {
  function testDefaultBehavior() public {
    assertEq(auraBalFarmer.token(), address(auraBal), "the token should be auraBal");
  }
}
