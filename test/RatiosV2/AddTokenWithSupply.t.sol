// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./RatiosV2Test.sol";

contract AddTokenWithSupply is RatiosV2Test {
  function testDefaultBehavior(address token, uint256 tokenRatio) public {
    vm.assume(token != zero && token != address(cvx) && token != address(aura));
    vm.assume(tokenRatio > 0);

    vm.prank(admin);
    ratiosV2.addTokenWithSupply(token, tokenRatio);
    assertEq(ratiosV2.warPerToken(token), tokenRatio);
    assertEq(ratiosV2.getTokenRatio(token), tokenRatio);
  }

  function testBaseTokens() public {
    // Token already added in setup just need to check
    assertGt(ratiosV2.warPerToken(address(aura)), 0);
    assertGt(ratiosV2.warPerToken(address(cvx)), 0);
    //assertEq(ratiosV2.warPerToken(address(cvx)), ratiosV2.warPerToken(address(aura)));
  }

  function testCantAddZeroAddress() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    vm.prank(admin);
    ratiosV2.addTokenWithSupply(zero, 500e18);
  }

  function testCantAddZeroSupply() public {
    vm.expectRevert(Errors.ZeroValue.selector);
    vm.prank(admin);
    ratiosV2.addTokenWithSupply(address(42), 0);
  }

  function testCantAddAlreadyExistingToken() public {
    vm.expectRevert(Errors.RatioAlreadySet.selector);
    vm.prank(admin);
    ratiosV2.addTokenWithSupply(address(cvx), 50e18);
  }
}
