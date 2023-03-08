// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./AuraBalFarmerTest.sol";

contract IsTokenSupported is AuraBalFarmerTest {
  function testDefaultBehavior() public {
    assertTrue(expose(auraBalFarmer).e_isTokenSupported(address(auraBal)), "auraBal should be supported");
    assertTrue(expose(auraBalFarmer).e_isTokenSupported(address(bal)), "bal should be supported");
  }

  function testTokenNotSupported(address token) public {
    vm.assume(token != address(auraBal) && token != address(bal));
    assertFalse(expose(auraBalFarmer).e_isTokenSupported(address(token)), "random token should not be supported");
  }
}
