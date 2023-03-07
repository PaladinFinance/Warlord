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
  WarBaseFarmer dummyFarmer;

  function setUp() public virtual override {
    MainnetTest.setUp();
    fork();

    vm.startPrank(admin);
    war = new WarToken();
    warStaker = new WarStaker(address(war));
    dummyFarmer = new WarDummyFarmer(controller, address(warStaker));
    vm.stopPrank();
  }
}

contract WarDummyFarmer is WarBaseFarmer {
  constructor(address _controller, address _warStaker) WarBaseFarmer(_controller, _warStaker) {}
  function stake(address _token, uint256 _amount) external {}
  function harvest() external {}
  function sendTokens(address receiver, uint256 amount) external {}
  function migrate(address receiver) external override {}
  function token() external view returns (address) {}

  function rewardTokens() external view returns (address[] memory) {
    address[] memory tokens = new address[](1);
    return tokens;
  }
}
