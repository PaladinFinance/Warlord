// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./RatiosTest.sol";

contract AddTokenWithSupply is RatiosTest {
  function testDefaultBehavior(address token, uint256 maxSupply) public {
    vm.assume(token != zero && token != address(cvx) && token != address(aura));
    vm.assume(maxSupply > 0);

    vm.prank(admin);
    oldRatios.addTokenWithSupply(token, maxSupply);
    assertEq(oldRatios.warPerToken(token), MAX_WAR_SUPPLY_PER_TOKEN * UNIT / maxSupply);
    assertEq(oldRatios.getTokenRatio(token), MAX_WAR_SUPPLY_PER_TOKEN * UNIT / maxSupply);
  }

  function testBaseTokens() public {
    // Token already added in setup just need to check
    assertGt(oldRatios.warPerToken(address(aura)), 0);
    assertGt(oldRatios.warPerToken(address(cvx)), 0);
    assertEq(oldRatios.warPerToken(address(cvx)), oldRatios.warPerToken(address(aura)));
  }

  function testCantAddZeroAddress() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    vm.prank(admin);
    oldRatios.addTokenWithSupply(zero, 500e18);
  }

  function testCantAddZeroSupply() public {
    vm.expectRevert(Errors.ZeroValue.selector);
    vm.prank(admin);
    oldRatios.addTokenWithSupply(address(42), 0);
  }

  function testCantAddAlreadyExistingToken() public {
    vm.expectRevert(Errors.SupplyAlreadySet.selector);
    vm.prank(admin);
    oldRatios.addTokenWithSupply(address(cvx), 50e18);
  }
}
