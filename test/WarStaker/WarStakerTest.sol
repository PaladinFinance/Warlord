// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "../MainnetTest.sol";
import "../../src/WarStaker.sol";
import "../../src/WarToken.sol";

contract WarStakerTest is MainnetTest {
  address admin = makeAddr("admin");

  WarStaker staker;
  WarToken war;

  function setUp() public override {
    MainnetTest.setUp();
    fork();

    war = new WarToken(admin);
    vm.prank(admin);
    staker = new WarStaker(address(war));
  }
}
