// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "../WarlordTest.sol";
import "src/Ratios.sol";

contract RatiosTest is WarlordTest {
  uint256 constant UNIT = 1e18;
  uint256 constant MAX_WAR_SUPPLY_PER_TOKEN = 100_000_000 * 1e18;
  uint256 constant MINT_PRECISION_LOSS = 1;

  uint256 constant cvxMaxSupply = 100_000_000e18;
  uint256 constant auraMaxSupply = 100_000_000e18;

  function setUp() public override {
    MainnetTest.setUp();
    fork();

    vm.startPrank(admin);
    oldRatios = new WarRatios();
    oldRatios.addToken(address(cvx), cvxMaxSupply);
    oldRatios.addToken(address(aura), auraMaxSupply);
    vm.stopPrank();
  }
}
