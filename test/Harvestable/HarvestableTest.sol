// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "../MainnetTest.sol";
import {Harvestable} from "src/Harvestable.sol";

contract HarvestableTest is MainnetTest {
  Harvestable dummyHarvestable;

  function setUp() public virtual override {
    vm.prank(admin);
    dummyHarvestable = new DummyHarvestable();
  }
}

contract DummyHarvestable is Harvestable {
  function harvest() external {}
}
