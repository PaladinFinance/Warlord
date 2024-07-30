// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "../WarlordTest.sol";
import "src/RatiosV3.sol";

contract RatiosV3Test is WarlordTest {
  uint256 constant UNIT = 1e18;
  uint256 constant MINT_PRECISION_LOSS = 10; // Because AURA ratio is 0.5 (1 AURA mints 0.5 WAR)

  uint256 constant cvxMaxSupply = 100_000_000e18;
  uint256 constant auraMaxSupply = 100_000_000e18;

  mapping(address => uint256) public setWarPerToken;

  WarRatiosV3 public ratiosV3;

  function setUp() public override {
    MainnetTest.setUp();
    fork();

    setWarPerToken[address(cvx)] = CVX_MINT_RATIO;
    setWarPerToken[address(aura)] = AURA_MINT_RATIO;

    vm.startPrank(admin);
    ratiosV3 = new WarRatiosV3();
    ratiosV3.addToken(address(cvx), CVX_MINT_RATIO);
    ratiosV3.addToken(address(aura), AURA_MINT_RATIO);
    vm.stopPrank();
  }
}
