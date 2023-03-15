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

  event SetController(address controller);
  event SetWarStaker(address warStaker);
  event Staked(uint256 amount);

  function setUp() public virtual override {
    MainnetTest.setUp();
    fork();

    vm.startPrank(admin);
    war = new WarToken();
    warStaker = new WarStaker(address(war));
    dummyFarmer = new WarDummyFarmer(controller, address(warStaker));
    vm.stopPrank();
  }

  modifier enableReentrancy() {
    WarDummyFarmer(address(dummyFarmer))._enableReentrancy();
    _;
  }
}

contract WarDummyFarmer is WarBaseFarmer {
  BaseFarmerReentrance reentrancy;

  constructor(address _controller, address _warStaker) WarBaseFarmer(_controller, _warStaker) {
    reentrancy = new BaseFarmerReentrance();
  }

  function _stake(address, /* _token*/ uint256 _amount) internal override returns (uint256) {
    reentrancy.trigger();
    return _amount;
  }

  function _harvest() internal override {
    reentrancy.trigger();
  }

  function _sendTokens(address, /*receiver*/ uint256 /*amount*/ ) internal override {
    reentrancy.trigger();
  }

  function _migrate(address receiver) internal pure override {}
  function token() external view returns (address) {}

  function _isTokenSupported(address /*_token*/ ) internal pure override returns (bool) {
    return true;
  }

  function _stakedBalance() internal pure override returns (uint256) {
    return type(uint256).max;
  }

  function _enableReentrancy() external {
    reentrancy.enable();
  }
}

contract BaseFarmerReentrance {
  WarDummyFarmer staker;
  bool enabled;

  constructor() {
    staker = WarDummyFarmer(msg.sender);
  }

  function enable() external {
    enabled = true;
  }

  function trigger() external {
    if (enabled) {
      staker.stake(address(0x1234), 1);
    }
  }
}
