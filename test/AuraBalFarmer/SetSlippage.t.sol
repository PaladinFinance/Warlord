// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./AuraBalFarmerTest.sol";

contract SetSlippage is AuraBalFarmerTest {
  function testDefaultBehavior(uint256 bps) public {
    vm.assume(bps < 500);
    assertEq(auraBalFarmer.slippageBps(), 9950);

    vm.expectEmit(true, false, false, true);
    emit SetSlippage(auraBalFarmer.slippageBps(), 10_000 - bps);

    vm.prank(admin);
    auraBalFarmer.setSlippage(bps);
    assertEq(auraBalFarmer.slippageBps(), 10_000 - bps);
  }

  function testSlippageTooHigh(uint256 bps) public {
    vm.assume(bps > 500);
    vm.prank(admin);
    vm.expectRevert(Errors.SlippageTooHigh.selector);
    auraBalFarmer.setSlippage(bps);
  }

  function testOnlyOwner(uint256 bps) public {
    vm.expectRevert("Ownable: caller is not the owner");
    auraBalFarmer.setSlippage(bps);
  }
}
