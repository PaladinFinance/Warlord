// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./MainnetTest.sol";
import "script/Deploy.s.sol";

contract WarlordTest is MainnetTest, Deployment {
  // Fuzzing upperbound (assuming war wraps 50 governance tokens);
  uint256 constant WAR_SUPPLY_UPPER_BOUND = 10_000e18 * 50;

  function setUp() public virtual override {
    MainnetTest.setUp();
    fork();

    vm.startPrank(admin);

    Deployment.deploy();

    // Distributor is not part of deployment due to governance discussion but still tested
    distributor = new HolyPaladinDistributor(address(hPal), address(war), distributionManager);

    vm.stopPrank();
  }
}
