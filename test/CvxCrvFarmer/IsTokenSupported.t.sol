// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./CvxCrvFarmerTest.sol";

contract IsTokenSupported is CvxCrvFarmerTest {
  function testDefaultBehavior() public {
    assertTrue(expose(cvxCrvFarmer).e_isTokenSupported(address(cvxCrv)), "cvxCrv should be supported");
    assertTrue(expose(cvxCrvFarmer).e_isTokenSupported(address(crv)), "crv should be supported");
  }

  function testTokenNotSupported(address token) public {
    vm.assume(token != address(cvxCrv) && token != address(crv));
    assertFalse(expose(cvxCrvFarmer).e_isTokenSupported(address(token)), "random token should not be supported");
  }
}
