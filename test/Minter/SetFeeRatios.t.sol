// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./MinterTest.sol";

contract SetRatios is MinterTest {
  function testDefaultBehavior(address newRatios) public {
    vm.assume(newRatios != zero);

    vm.expectEmit(true, false, false, true);
    emit MintRatioUpdated(address(minter.ratios()), newRatios);

    vm.prank(admin);
    minter.setRatios(newRatios);
    assertEq(address(minter.ratios()), newRatios, "new ratios should be assigned correctly");
  }

  function testZeroAddress() public {
    vm.expectRevert(Errors.ZeroAddress.selector);

    vm.prank(admin);
    minter.setRatios(zero);
  }

  function testOnlyOwner(address newRatios) public {
    vm.expectRevert("Ownable: caller is not the owner");
    minter.setRatios(newRatios);
  }
}
