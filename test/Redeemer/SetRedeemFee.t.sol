// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./RedeemerTest.sol";

contract SetRedeemFee is RedeemerTest {
  function testDefaultBehavior(uint256 fee) public {
    vm.assume(fee > 0 && fee < 1000);

    vm.expectEmit(true, false, false, true);
    emit RedeemFeeUpdated(redeemer.redeemFee(), fee);

    vm.prank(admin);
    redeemer.setRedeemFee(fee);
    assertEqDecimal(redeemer.redeemFee(), fee, 2, "redeem fee should be assigned correctly");
  }

  function testInvalidParameterZero() public {
    vm.expectRevert(Errors.InvalidParameter.selector);

    vm.prank(admin);
    redeemer.setRedeemFee(0);
  }

  function testInvalidParameterTooBig(uint256 fee) public {
    vm.assume(fee > 1000);

    vm.expectRevert(Errors.InvalidParameter.selector);

    vm.prank(admin);
    redeemer.setRedeemFee(fee);
  }

  function testOnlyOwner(uint256 fee) public {
    vm.expectRevert("Ownable: caller is not the owner");
    redeemer.setRedeemFee(fee);
  }
}
