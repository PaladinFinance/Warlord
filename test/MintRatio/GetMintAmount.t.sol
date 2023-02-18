// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./MintRatioTest.sol";

contract GetMintAmount is MintRatioTest {
  function testMaxWarSupplyCvx() public {
    _maxWarSupplyPerToken(address(cvx), cvxMaxSupply);
  }

  function testMaxWarSupplyAura() public {
    _maxWarSupplyPerToken(address(aura), auraMaxSupply);
  }

  function _maxWarSupplyPerToken(address token, uint256 maxSupply) internal {
    uint256 mintAmount = mintRatio.getMintAmount(token, maxSupply);
    assertEq(mintAmount, MAX_WAR_SUPPLY_PER_TOKEN);
  }

  function testHalfWarSupplyCvx() public {
    _halfWarSupplyPerToken(address(cvx), cvxMaxSupply);
  }

  function testHalfWarSupplyAura() public {
    _halfWarSupplyPerToken(address(aura), auraMaxSupply);
  }

  function _halfWarSupplyPerToken(address token, uint256 maxSupply) public {
    uint256 mintAmount = mintRatio.getMintAmount(token, maxSupply / 2);
    assertEq(mintAmount, MAX_WAR_SUPPLY_PER_TOKEN / 2);
  }

  function _defaultBehavior(address token, uint256 maxSupply, uint256 amount) internal {
    vm.assume(amount >= 1e4 && amount <= maxSupply);
    uint256 mintAmount = mintRatio.getMintAmount(address(token), amount);
    assertGt(mintAmount, 0);
  }

  function testDefaultBehaviorWithAura(uint256 amount) public {
    _defaultBehavior(address(aura), auraMaxSupply, amount);
  }

  function testDefaultBehaviorWithCvx(uint256 amount) public {
    _defaultBehavior(address(cvx), cvxMaxSupply, amount);
  }

  function _precisionLoss(address token, uint256 amount) internal {
    assertEq(mintRatio.getMintAmount(token, amount), 0);
  }

  function testCvxPrecisionLoss(uint256 amount) public {
    vm.assume(amount > 0 && amount < 1e4);
    _precisionLoss(address(cvx), amount);
  }

  function testAuraPrecisionLoss(uint256 amount) public {
    vm.assume(amount > 0 && amount < 1e4);
    _precisionLoss(address(aura), amount);
  }

  function tesZeroAddress() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    mintRatio.getMintAmount(zero, 1e10);
  }

  function testZeroAmount() public {
    vm.expectRevert(Errors.ZeroValue.selector);
    mintRatio.getMintAmount(address(aura), 0);
  }
}
