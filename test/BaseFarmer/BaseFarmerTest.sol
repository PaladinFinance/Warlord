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
  uint256 stakedBalance;
  constructor(address _controller, address _warStaker) WarBaseFarmer(_controller, _warStaker) {}
  function _stake(address _token, uint256 _amount) internal override returns (uint256) {
    stakedBalance += amount;
  }
  function _harvest() internal override {}
  function _sendTokens(address receiver, uint256 amount) internal {}
  function _migrate(address receiver) internal override {}
  function token() external view returns (address) {}
  function _isTokenSupported(address _token);
}
