// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "../MainnetTest.sol";
import "../../src/IncentivizedLocker.sol";

contract IncentivizedLockerTest is MainnetTest {
  IncentivizedLocker dummyLocker;
  address controller;
  address redeemModule;
  address warMinter;
  address delegate;

  function setUp() public virtual override {
    MainnetTest.setUp();
    fork();

    controller = makeAddr("controller");
    redeemModule = makeAddr("redeemModule");
    warMinter = makeAddr("warMinter");
    delegate = makeAddr("delegate");
    dummyLocker = new DummyIncentivizedLocker(controller, redeemModule, warMinter, delegate);
  }

  function deployLockerAt(address target) public returns (IncentivizedLocker) {
    require(target > address(10)); // avoid conflicts with precompiled contracts
    bytes memory code = address(dummyLocker).code;
    vm.etch(target, code);
    return IncentivizedLocker(target);
  }
}

contract DummyIncentivizedLocker is IncentivizedLocker {
  constructor(address _controller, address _redeemModule, address _warMinter, address _delegatee)
    WarBaseLocker(_controller, _redeemModule, _warMinter, _delegatee)
  {}
  function _harvest() internal override {}
  function _lock(uint256 amount) internal override {}
  function _migrate(address receiver) internal override {}
  function _processUnlock() internal override {}
  function _setDelegate(address _delegatee) internal override {}
  function token() external view returns (address none) {}
}
