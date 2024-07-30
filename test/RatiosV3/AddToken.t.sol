// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./RatiosV3Test.sol";

contract AddToken is RatiosV3Test {
  function testDefaultBehavior(address token, uint256 tokenRatio) public {
    vm.assume(token != zero && token != address(cvx) && token != address(aura));
    vm.assume(tokenRatio > 0);

    vm.prank(admin);
    ratiosV3.addToken(token, tokenRatio);
    assertEq(ratiosV3.warPerToken(token), tokenRatio);
    assertEq(ratiosV3.getTokenRatio(token), tokenRatio);
  }

  function testBaseTokens() public {
    // Token already added in setup just need to check
    assertGt(ratiosV3.warPerToken(address(aura)), 0);
    assertGt(ratiosV3.warPerToken(address(cvx)), 0);
    //assertEq(ratiosV3.warPerToken(address(cvx)), ratiosV3.warPerToken(address(aura)));
  }

  function testCantAddZeroAddress() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    vm.prank(admin);
    ratiosV3.addToken(zero, 500e18);
  }

  function testCantAddZeroSupply() public {
    vm.expectRevert(Errors.ZeroValue.selector);
    vm.prank(admin);
    ratiosV3.addToken(address(42), 0);
  }

  function testCantAddAlreadyExistingToken() public {
    vm.expectRevert(Errors.RatioAlreadySet.selector);
    vm.prank(admin);
    ratiosV3.addToken(address(cvx), 50e18);
  }
}
