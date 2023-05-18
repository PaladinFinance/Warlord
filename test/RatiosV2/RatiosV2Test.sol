// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "../WarlordTest.sol";
import "src/RatiosV2.sol";

contract RatiosV2Test is WarlordTest {
  uint256 constant UNIT = 1e18;
  uint256 constant MINT_PRECISION_LOSS = 10; // Because AURA ratio is 0.5 (1 AURA mints 0.5 WAR)

  uint256 constant cvxMaxSupply = 100_000_000e18;
  uint256 constant auraMaxSupply = 100_000_000e18;

  mapping(address => uint256) public setWarPerToken;

  function setUp() public override {
    MainnetTest.setUp();
    fork();

    setWarPerToken[address(cvx)] = CVX_MINT_RATIO;
    setWarPerToken[address(aura)] = AURA_MINT_RATIO;

    vm.startPrank(admin);
    ratios = new WarRatiosV2();
    ratios.addTokenWithSupply(address(cvx), CVX_MINT_RATIO);
    ratios.addTokenWithSupply(address(aura), AURA_MINT_RATIO);
    vm.stopPrank();
  }
}
