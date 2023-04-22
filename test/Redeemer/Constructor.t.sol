// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./RedeemerTest.sol";

contract Constructor is RedeemerTest {
  function testDefaultBehavior() public {
    assertEq(redeemer.war(), address(war), "Redeemer should refer to war token");
    assertEq(address(redeemer.ratios()), address(ratios), "Redeemer should refer to war ratios");
    assertEq(redeemer.feeReceiver(), redemptionFeeReceiver, "Redeemer should refer to the redemption fee receiver");
    assertEq(redeemer.redeemFee(), 500, "Redemption fee should be 5% at the beginning");
  }

  function testZeroAddressWar() public {
    vm.expectRevert(Errors.ZeroAddress.selector);

    new WarRedeemer(zero, address(ratios), redemptionFeeReceiver, REDEMPTION_FEE);
  }

  function testZeroAddressRatios() public {
    vm.expectRevert(Errors.ZeroAddress.selector);

    new WarRedeemer(address(war), zero, redemptionFeeReceiver, REDEMPTION_FEE);
  }

  function testZeroAddressFeeReceiver() public {
    vm.expectRevert(Errors.ZeroAddress.selector);

    new WarRedeemer(address(war), address(ratios), zero, REDEMPTION_FEE);
  }

  function testInvalidParameterZero() public {
    vm.expectRevert(Errors.InvalidParameter.selector);

    new WarRedeemer(address(war), address(ratios), redemptionFeeReceiver, 0);
  }

  function testInvalidParameterTooBig(uint256 fee) public {
    vm.assume(fee > 1000);

    vm.expectRevert(Errors.InvalidParameter.selector);

    new WarRedeemer(address(war), address(ratios), redemptionFeeReceiver, fee);
  }
}
