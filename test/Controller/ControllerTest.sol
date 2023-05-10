// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "../WarlordTest.sol";
import "src/Token.sol";
import {WarStaker} from "src/Staker.sol";
import {WarRatios} from "src/Ratios.sol";
import {WarMinter} from "src/Minter.sol";
import "src/Controller.sol";
import "src/IncentivizedLocker.sol";

contract ControllerTest is WarlordTest {
  event PullTokens(address indexed swapper, address indexed token, uint256 amount);
  event SetMinter(address oldMinter, address newMinter);
  event SetStaker(address oldStaker, address newStaker);
  event SetSwapper(address oldSwapper, address newSwapper);
  event SetFeeReceiver(address oldFeeReceiver, address newFeeReceiver);
  event SetIncentivesClaimer(address oldIncentivesClaimer, address newIncentivesClaimer);
  event SetFeeRatio(uint256 oldFeeRatio, uint256 newFeeRatio);
  event SetLocker(address indexed token, address locker);
  event SetFarmer(address indexed token, address famer);
  event SetDistributionToken(address indexed token, bool distribution);
  event SetHarvestable(address harvestable, bool enabled);

  IIncentivizedLocker dummyLocker;
  address[] queueableRewards;

  function popoulateRewards() public {
    queueableRewards.push(address(war));
    queueableRewards.push(address(pal));
    queueableRewards.push(address(weth));
    queueableRewards.push(address(cvxFxs));
  }

  function setUp() public virtual override {
    WarlordTest.setUp();
    popoulateRewards();
    init();
  }

  function init() public {
    vm.prank(admin);
    controller =
    new Exposed_Controller(address(war), address(minter), address(staker), swapper, incentivesClaimer, protocolFeeReceiver);
    dummyLocker =
      new DummyIncentivizedLocker(address(controller), makeAddr("redeemModule"), address(minter), makeAddr("delegate"));
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

contract UnexposedControllerTest is ControllerTest {
  function setUp() public virtual override {
    WarlordTest.setUp();
    popoulateRewards();
  }

  function computeFee(uint256 balance) public view returns (uint256) {
    return (balance * controller.feeRatio()) / 10_000;
  }
}

contract Exposed_Controller is WarController {
  constructor(
    address _war,
    address _minter,
    address _staker,
    address _swapper,
    address _incentivesClaimer,
    address _feeReceiver
  ) WarController(_war, _minter, _staker, _swapper, _incentivesClaimer, _feeReceiver) {}

  function getFarmersLength() public view returns (uint256) {
    return farmers.length;
  }

  function getLockersLength() public view returns (uint256) {
    return lockers.length;
  }
}

function expose(WarController c) pure returns (Exposed_Controller) {
  return Exposed_Controller(address(c));
}

contract QuestTest is ControllerTest {
  function setUp() public virtual override {
    WarlordTest.setUp();

    // https://etherscan.io/tx/0x69748ad386d6455d1c0c2d1fa0f63ca1c025b0c2787f0911ac032f93250dc52e
    vm.createSelectFork(vm.rpcUrl("ethereum_alchemy"), 16_852_914);

    init();
  }
}

contract DelegationAddressTest is ControllerTest {
  function setUp() public virtual override {
    WarlordTest.setUp();

    // https://etherscan.io/tx/0x869e684381f31a6282779a453bbc4e89352f7c4400890d29747108a5ccf5ce70
    vm.createSelectFork(vm.rpcUrl("ethereum_alchemy"), 17_137_056);

    init();
  }
}

contract VotiumTest is ControllerTest {
  function setUp() public virtual override {
    WarlordTest.setUp();

    // https://etherscan.io/tx/0xf8c0aa5f030fb808b8536f794036921a0b4bcd3324abe642961fd77820c56ef4
    vm.createSelectFork(vm.rpcUrl("ethereum_alchemy"), 17_142_838);

    init();
  }
}

contract HiddenHandTest is ControllerTest {
  function setUp() public virtual override {
    WarlordTest.setUp();

    // https://etherscan.io/tx/0xda4319f4f8f1da3c46a26073191c28017066c13309e38afcb28e7a7f0cf58371
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
