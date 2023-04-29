// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "../MainnetTest.sol";
import "src/IncentivizedLocker.sol";

contract IncentivizedLockerTest is MainnetTest {
  IncentivizedLocker dummyLocker;
  address controller;
  address redeemModule;
  address warMinter;
  address delegate;

  function init() public {
    controller = makeAddr("controller");
    redeemModule = makeAddr("redeemModule");
    warMinter = makeAddr("warMinter");
    delegate = makeAddr("delegate");
    dummyLocker = new DummyIncentivizedLocker(controller, redeemModule, warMinter, delegate);
  }

  function deployLockerAt(address target) public returns (IncentivizedLocker) {
    bytes32[] memory targetMemory = new bytes32[](9);
    // Copy contract storage to stack
    for (uint256 i; i < targetMemory.length; i++) {
      targetMemory[i] = vm.load(address(dummyLocker), bytes32(i));
    }
    require(target > address(10)); // avoid conflicts with precompiled contracts
    bytes memory code = address(dummyLocker).code;
    vm.etch(target, code);
    for (uint256 i; i < targetMemory.length; i++) {
      vm.store(target, bytes32(i), targetMemory[i]);
    }
    return IncentivizedLocker(target);
  }
}

contract QuestTest is IncentivizedLockerTest {
  function setUp() public virtual override {
    MainnetTest.setUp();

    // https://etherscan.io/tx/0x69748ad386d6455d1c0c2d1fa0f63ca1c025b0c2787f0911ac032f93250dc52e
    vm.createSelectFork(vm.rpcUrl("ethereum_alchemy"), 16_852_914);

    init();
  }
}

contract DelegationAddressTest is IncentivizedLockerTest {
  function setUp() public virtual override {
    MainnetTest.setUp();

    // https://etherscan.io/tx/0x869e684381f31a6282779a453bbc4e89352f7c4400890d29747108a5ccf5ce70
    vm.createSelectFork(vm.rpcUrl("ethereum_alchemy"), 17_137_056);

    init();
  }
}

contract VotiumTest is IncentivizedLockerTest {
  function setUp() public virtual override {
    MainnetTest.setUp();

    // https://etherscan.io/tx/0xf8c0aa5f030fb808b8536f794036921a0b4bcd3324abe642961fd77820c56ef4
    vm.createSelectFork(vm.rpcUrl("ethereum_alchemy"), 17_142_838);

    init();
  }
}

contract HiddenHandTest is IncentivizedLockerTest {
  function setUp() public virtual override {
    MainnetTest.setUp();

    // https://etherscan.io/tx/0x6a7e234f357cc0695d3202df1b6d219a7a60dc48915aeaae6cf57d7e3390608d
    vm.createSelectFork(vm.rpcUrl("ethereum_alchemy"), 17_136_627);

    init();
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
