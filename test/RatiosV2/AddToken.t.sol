// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./RatiosV2Test.sol";

contract AddToken is RatiosV2Test {
  function testDefaultBehavior(address token, uint256 tokenRatio) public {
    vm.assume(token != zero && token != address(cvx) && token != address(aura));
    vm.assume(tokenRatio > 0);

    vm.prank(admin);
    ratios.addToken(token, tokenRatio);
    assertEq(ratios.warPerToken(token), tokenRatio);
    assertEq(ratios.getTokenRatio(token), tokenRatio);
  }

  function testBaseTokens() public {
    // Token already added in setup just need to check
    assertGt(ratios.warPerToken(address(aura)), 0);
    assertGt(ratios.warPerToken(address(cvx)), 0);
    //assertEq(ratios.warPerToken(address(cvx)), ratios.warPerToken(address(aura)));
  }

  function testCantAddZeroAddress() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    vm.prank(admin);
    ratios.addToken(zero, 500e18);
  }

  function testCantAddZeroSupply() public {
    vm.expectRevert(Errors.ZeroValue.selector);
    vm.prank(admin);
    ratios.addToken(address(42), 0);
  }

  function testCantAddAlreadyExistingToken() public {
    vm.expectRevert(Errors.RatioAlreadySet.selector);
    vm.prank(admin);
    ratios.addToken(address(cvx), 50e18);
  }
}
