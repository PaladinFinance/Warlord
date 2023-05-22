// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "../MainnetTest.sol";
import "src/BaseLocker.sol";
import {WarStaker} from "src/Staker.sol";
import "src/Token.sol";
import "src/Ratios.sol";
import "mocks/MockRedeemModule.sol";

contract BaseLockerTest is MainnetTest {
  address controller = makeAddr("controller");
  address delegate = makeAddr("delegate");
  WarToken war;
  WarRatios ratios;
  WarMinter minter;
  MockRedeem redeemModule;
  WarDummyLocker dummyLocker;

  event SetController(address newController);
  event SetRedeemModule(address newRedeemModule);
  event SetDelegate(address newDelegatee);
  event Shutdown();

  function setUp() public virtual override {
    MainnetTest.setUp();
    fork();

    vm.startPrank(admin);
    war = new WarToken();
    ratios = new WarRatios();
    minter = new WarMinter(address(war), address(ratios));
    redeemModule = new MockRedeem();
    dummyLocker = new WarDummyLocker(controller, address(redeemModule), address(minter), delegate);
    vm.stopPrank();
  }
}

contract WarDummyLocker is WarBaseLocker {
  constructor(address _controller, address _redeemModule, address _warMinter, address _delegate)
    WarBaseLocker(_controller, _redeemModule, _warMinter, _delegate)
  {}
  function sendTokens(address receiver, uint256 amount) external {}
  function _lock(uint256 amount) internal override {}
  function _harvest() internal override {}
  function _migrate(address receiver) internal override {}
  function _processUnlock() internal override {}
  function _setDelegate(address delegatee) internal override {}

  function getCurrentLockedTokens() external pure override returns (uint256) {
    return 1_234_565;
  }

  function token() external pure returns (address) {
    return address(0x1234123412341234);
  }
}
