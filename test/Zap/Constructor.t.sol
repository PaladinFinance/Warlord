// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./ZapTest.sol";

contract Constructor is ZapTest {
  function testDefaultBehavior() public {
    assertEq(address(zap.warToken()), address(war), "war token is not assigned correctly in constructor");
    assertEq(address(zap.minter()), address(minter), "war minter is not assigned correctly in constructor");
    assertEq(address(zap.staker()), address(staker), "war staker is not assigned correctly in constructor");
  }

  function testZeroAddressMinter() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    new WarZap(zero, address(staker), address(war));
  }

  function testZeroAddressStaker() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    new WarZap(address(minter), zero, address(war));
  }

  function testZeroAddressWar() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    new WarZap(address(minter), address(staker), zero);
  }

  function testMaxAllowance() public {
    assertEqDecimal(
      IERC20(address(war)).allowance(address(zap), address(staker)),
      type(uint256).max,
      18,
      "allowance should be set to max"
    );
  }
}
