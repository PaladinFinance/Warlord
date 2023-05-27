// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "./E2ETest.sol";

contract Migration is E2ETest {
  function testScenario() public {
    (, RewardAndAmount[] memory rewards) = fuzzRewardsAndStakers(12349087, 100000);

    for (uint256 i; i < rewards.length; ++i) {
      console.log("fuzzed %s for %e", vm.getLabel(rewards[i].reward), rewards[i].amount);
    }

    address migrationReceiver = makeAddr("migrationReceiver");

    deal(address(aura), address(this), 1234e18);
    deal(address(cvx), address(this), 1234e18);

    console.log("Initially deposited 1234e18 AURA and 1234e18 CVX");

    aura.approve(address(minter), 1234e18);
    cvx.approve(address(minter), 1234e18);
    minter.mint(address(aura), 1234e18);
    minter.mint(address(cvx), 1234e18);
    vm.warp(block.timestamp + 20 weeks);

    vm.startPrank(admin);
    // Pausing everything
    auraBalFarmer.pause();
    auraLocker.pause();
    cvxCrvFarmer.pause();
    cvxLocker.pause();

    auraBalFarmer.migrate(migrationReceiver);
    auraLocker.migrate(migrationReceiver);
    cvxCrvFarmer.migrate(migrationReceiver);
    cvxLocker.migrate(migrationReceiver);
    vm.stopPrank();

    console.log("migration receiver has %e auraBal", auraBal.balanceOf(migrationReceiver));
    console.log("controller received %e auraBal from migration harvest", auraBal.balanceOf(migrationReceiver));
    console.log("migration receiver has %e aura", aura.balanceOf(migrationReceiver));
    console.log("migration receiver has %e cvxCrv", auraBal.balanceOf(migrationReceiver));
    console.log("migration receiver has %e cvx", cvx.balanceOf(migrationReceiver));
  }
}
