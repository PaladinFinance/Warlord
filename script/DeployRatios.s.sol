// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "forge-std/Script.sol";
import "test/MainnetTest.sol";

// Infrastructure
import {WarRatiosV2} from "src/RatiosV2.sol";

contract Deployment is Script, MainnetTest {
  WarRatiosV2 ratios;

  function run() public {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);

    deploy();

    vm.stopBroadcast();
  }

  function deploy() public {
    ratios = new WarRatiosV2();
  }
}
