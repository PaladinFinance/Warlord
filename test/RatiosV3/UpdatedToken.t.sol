// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./RatiosV3Test.sol";

contract UpdateToken is RatiosV3Test {
  function testDefaultBehavior(uint256 tokenRatio) public {
    vm.assume(tokenRatio > 0);

    vm.prank(admin);
    ratiosV3.freezeRatios();

    vm.prank(admin);
    ratiosV3.updateToken(address(cvx), tokenRatio);
    assertEq(ratiosV3.warPerToken(address(cvx)), tokenRatio);
    assertEq(ratiosV3.getTokenRatio(address(cvx)), tokenRatio);
  }

  function testCantUpdateZeroAddress() public {
    vm.prank(admin);
    ratiosV3.freezeRatios();

    vm.expectRevert(Errors.ZeroAddress.selector);
    vm.prank(admin);
    ratiosV3.updateToken(zero, 500e18);
  }

  function testCantUpdateZeroValue() public {
    vm.prank(admin);
    ratiosV3.freezeRatios();

    vm.expectRevert(Errors.ZeroValue.selector);
    vm.prank(admin);
    ratiosV3.updateToken(address(42), 0);
  }

  function testCantUpdateNotExistingToken() public {
    vm.prank(admin);
    ratiosV3.freezeRatios();

    vm.expectRevert(Errors.RatioNotSet.selector);
    vm.prank(admin);
    ratiosV3.updateToken(address(5555), 50e18);
  }

  function testUpdateIfNotFrozen() public {
    vm.expectRevert(Errors.RatiosNotFrozen.selector);
    vm.prank(admin);
    ratiosV3.updateToken(address(cvx), 50e18);
  }
}
