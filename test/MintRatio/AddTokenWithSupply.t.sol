// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./MintRatioTest.sol";

contract AddTokenWithSupply is MintRatioTest {
  function testDefaultBehavior() public {
    MockERC20 mock = new MockERC20();
    mintRatio.addTokenWithSupply(address(mock), 500e18);

    uint256 mintAmount = mintRatio.getMintAmount(address(mock), 500);
    assertEq(mintAmount, 1);
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
