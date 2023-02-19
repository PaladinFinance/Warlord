// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "../MainnetTest.sol";
import "../../src/BaseFarmer.sol";
import {WarStaker} from "../../src/Staker.sol";
import "../../src/Token.sol";

contract BaseFarmerTest is MainnetTest {
  address controller = makeAddr("controller");
  WarToken war;
  WarStaker warStaker;
  WarBaseFarmer warMockFarmer;

  function setUp() public virtual override {
    MainnetTest.setUp();
    fork();

    vm.startPrank(admin);
    war = new WarToken();
    warStaker = new WarStaker(address(war));
    warMockFarmer = new WarMockFarmer(controller, address(warStaker));
    vm.stopPrank();
  }
}

contract WarMockFarmer is WarBaseFarmer {
  constructor(address _controller, address _warStaker) WarBaseFarmer(_controller, _warStaker) {}
  function harvest() external {}
  function sendTokens(address receiver, uint256 amount) external {}
  function migrate(address receiver) external override {}
}
