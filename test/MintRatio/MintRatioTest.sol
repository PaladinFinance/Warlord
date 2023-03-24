// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "../MainnetTest.sol";
import "src/Ratios.sol";

contract MintRatioTest is MainnetTest {
  WarRatios ratios;

  uint256 constant UNIT = 1e18;
  uint256 constant MAX_WAR_SUPPLY_PER_TOKEN = 10_000 * 1e18;
  uint256 constant MINT_PRECISION_LOSS = 1e6;

  uint256 constant cvxMaxSupply = 100_000_000e18;
  uint256 constant auraMaxSupply = 100_000_000e18;

  function setUp() public override {
    MainnetTest.setUp();
    fork();

    vm.startPrank(admin);
    ratios = new WarRatios();
    ratios.addTokenWithSupply(address(cvx), cvxMaxSupply);
    ratios.addTokenWithSupply(address(aura), auraMaxSupply);
  }
}
