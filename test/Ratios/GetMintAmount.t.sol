// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./RatiosTest.sol";

contract GetMintAmount is RatiosTest {
  function testMaxWarSupplyCvx() public {
    _maxWarSupplyPerToken(address(cvx), cvxMaxSupply);
  }

  function testMaxWarSupplyAura() public {
    _maxWarSupplyPerToken(address(aura), auraMaxSupply);
  }

  function _maxWarSupplyPerToken(address token, uint256 maxSupply) internal {
    uint256 mintAmount = oldRatios.getMintAmount(token, maxSupply);
    assertEq(mintAmount, MAX_WAR_SUPPLY_PER_TOKEN);
  }

  function testHalfWarSupplyCvx() public {
    _halfWarSupplyPerToken(address(cvx), cvxMaxSupply);
  }

  function testHalfWarSupplyAura() public {
    _halfWarSupplyPerToken(address(aura), auraMaxSupply);
  }

  function _halfWarSupplyPerToken(address token, uint256 maxSupply) public {
    uint256 mintAmount = oldRatios.getMintAmount(token, maxSupply / 2);
    assertEq(mintAmount, MAX_WAR_SUPPLY_PER_TOKEN / 2);
  }

  function _defaultBehavior(address token, uint256 maxSupply, uint256 amount) internal {
    vm.assume(amount >= 1e4 && amount <= maxSupply);
    uint256 mintAmount = oldRatios.getMintAmount(address(token), amount);
    assertGt(mintAmount, 0);
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
    oldRatios.addTokenWithSupply(token, cvxMaxSupply * 1e4);

    assertEq(oldRatios.getMintAmount(token, amount), 0);
  }

  function testZeroAddress(uint256 amount) public {
    vm.assume(amount != 0);

    vm.expectRevert(Errors.ZeroAddress.selector);
    oldRatios.getMintAmount(zero, amount);
  }

  function testZeroAmount(address token) public {
    vm.assume(token != zero);

    vm.expectRevert(Errors.ZeroValue.selector);
    oldRatios.getMintAmount(token, 0);
  }
}
