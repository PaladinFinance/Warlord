// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./RedeemerTest.sol";

contract SetRatios is RedeemerTest {
  function testDefaultBehavior(address newRatios) public {
    vm.assume(newRatios != zero);

    vm.expectEmit();
    emit MintRatioUpdated(address(redeemer.ratios()), newRatios);

    vm.prank(admin);
    redeemer.setRatios(newRatios);
    assertEq(address(redeemer.ratios()), newRatios, "new ratios should be assigned correctly");
  }

  function testZeroAddress() public {
    vm.expectRevert(Errors.ZeroAddress.selector);

    vm.prank(admin);
    redeemer.setRatios(zero);
  }

  function testOnlyOwner(address newRatios) public {
    vm.expectRevert("Ownable: caller is not the owner");
    redeemer.setRatios(newRatios);
  }
}
