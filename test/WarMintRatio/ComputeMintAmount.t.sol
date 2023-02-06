// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./MintRatioTest.sol";

contract ComputeMintAmount is MintRatioTest {
  uint256 constant SUPPLY_UNIT = cvxMaxSupply / 1e18;

  function testMinCvxMintAmount() public {
    uint256 mintAmount = mintRatio.getMintAmount(address(cvx), SUPPLY_UNIT);
    assertEq(mintAmount, 1);
  }

  /*function testHalfSupplyCvxMintAmount() public {
    uint256 mintAmount = mintRatio.getMintAmount(address(cvx), cvxMaxSupply);
    console.log(mintAmount);
    // assertEq(mintAmount, 500_000_000_000_000_000);
    // TODO assertEq(mintAmount, 1_000_000_000_000_000_000);
  } */

  //TODO fuzz this

  function testRevertWithZeroAddress() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    mintRatio.getMintAmount(zero, 1e10);
  }

  function testRevertWithZeroAmount() public {
    vm.expectRevert(Errors.ZeroValue.selector);
    mintRatio.getMintAmount(address(cvx), 0);
  }
}
