// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./MintRatioTest.sol";

contract AddTokenWithSupply is MintRatioTest {
  function testDefaultBehavior() public {
    // Token already added in setup just need to check
    assertGt(mintRatio.warPerToken(address(aura)), 0);
    assertGt(mintRatio.warPerToken(address(cvx)), 0);
    assertEq(mintRatio.warPerToken(address(cvx)), mintRatio.warPerToken(address(cvx)));
  }

  function testCantAddZeroAddress() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    mintRatio.addTokenWithSupply(zero, 500e18);
  }

  function testCantAddZeroSupply() public {
    vm.expectRevert(Errors.ZeroValue.selector);
    mintRatio.addTokenWithSupply(address(42), 0);
  }

  function testCantAddAlreadyExistingToken() public {
    vm.expectRevert(Errors.SupplyAlreadySet.selector);
    mintRatio.addTokenWithSupply(address(cvx), 50e18);
  }
}
