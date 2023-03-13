// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./MintRatioTest.sol";

contract AddTokenWithSupply is MintRatioTest {
  function testDefaultBehavior(address token, uint256 maxSupply) public {
    vm.assume(token != zero);
    vm.assume(maxSupply > 0);

    mintRatio.addTokenWithSupply(token, maxSupply);
    assertEq(mintRatio.warPerToken(token), MAX_WAR_SUPPLY_PER_TOKEN * UNIT / maxSupply);
  }

  function testBaseTokens() public {
    // Token already added in setup just need to check
    assertGt(mintRatio.warPerToken(address(aura)), 0);
    assertGt(mintRatio.warPerToken(address(cvx)), 0);
    assertEq(mintRatio.warPerToken(address(cvx)), mintRatio.warPerToken(address(aura)));
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
