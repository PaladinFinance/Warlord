// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./RedeemerTest.sol";

contract SetFeeReceiver is RedeemerTest {
  function testDefaultBehavior(address receiver) public {
    vm.assume(receiver != zero);

    vm.expectEmit(true, false, false, true);
    emit FeeReceiverUpdated(redeemer.feeReceiver(), receiver);

    vm.prank(admin);
    redeemer.setFeeReceiver(receiver);
    assertEq(redeemer.feeReceiver(), receiver, "fee receiver should be assigned correctly");
  }

  function testZeroAddress() public {
    vm.expectRevert(Errors.ZeroAddress.selector);

    vm.prank(admin);
    redeemer.setFeeReceiver(zero);
  }

  function testOnlyOwner(address receiver) public {
    vm.expectRevert("Ownable: caller is not the owner");
    redeemer.setFeeReceiver(receiver);
  }
}
