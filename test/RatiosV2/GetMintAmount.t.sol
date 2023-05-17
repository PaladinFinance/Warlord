// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./RatiosV2Test.sol";

contract GetMintAmount is RatiosV2Test {

  function _defaultBehavior(address token, uint256 maxSupply, uint256 amount) internal {
    vm.assume(amount >= 1e4 && amount <= maxSupply);
    uint256 mintAmount = ratiosV2.getMintAmount(address(token), amount);
    assertGt(mintAmount, 0);

    uint256 expectedMintAmount = amount * setWarPerToken[token] / UNIT;

    assertEq(mintAmount, expectedMintAmount);
  }

  function testDefaultBehaviorWithAura(uint256 amount) public {
    _defaultBehavior(address(aura), auraMaxSupply, amount);
  }

  function testDefaultBehaviorWithCvx(uint256 amount) public {
    _defaultBehavior(address(cvx), cvxMaxSupply, amount);
  }

  function testPrecisionLoss(uint256 amount) public {
    vm.assume(amount > 0 && amount < 1e4);

    address token = makeAddr("otherToken");
    vm.prank(admin);
    ratiosV2.addTokenWithSupply(token, CVX_MINT_RATIO / 1e4);

    assertEq(ratiosV2.getMintAmount(token, amount), 0);
  }

  function testZeroAddress(uint256 amount) public {
    vm.assume(amount != 0);

    vm.expectRevert(Errors.ZeroAddress.selector);
    ratiosV2.getMintAmount(zero, amount);
  }

  function testZeroAmount(address token) public {
    vm.assume(token != zero);

    vm.expectRevert(Errors.ZeroValue.selector);
    ratiosV2.getMintAmount(token, 0);
  }
}
