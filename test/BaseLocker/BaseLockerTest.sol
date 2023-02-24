// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "../MainnetTest.sol";
import "../../src/BaseLocker.sol";
import {WarStaker} from "../../src/Staker.sol";
import "../../src/Token.sol";
import "../../src/MintRatio.sol";
import "mocks/MockRedeemModule.sol";

contract BaseLockerTest is MainnetTest {
  address controller = makeAddr("controller");
  address delegate = makeAddr("delegate");
  WarToken war;
  WarMintRatio mintRatio;
  WarMinter minter;
  MockRedeem redeemModule;
  WarDummyLocker dummyLocker;

  event SetController(address newController);
  event SetRedeemModule(address newRedeemModule);
  event Shutdown();

  function setUp() public virtual override {
    MainnetTest.setUp();
    fork();

    vm.startPrank(admin);
    war = new WarToken();
    mintRatio = new WarMintRatio();
    minter = new WarMinter(address(war), address(mintRatio));
    redeemModule = new MockRedeem();
    dummyLocker = new WarDummyLocker(controller, address(redeemModule), address(minter), delegate);
    vm.stopPrank();
  }
}

contract WarDummyLocker is WarBaseLocker, Test {
  constructor(address _controller, address _redeemModule, address _warMinter, address _delegate)
    WarBaseLocker(_controller, _redeemModule, _warMinter, _delegate)
  {}
  function sendTokens(address receiver, uint256 amount) external {}
  function _lock(uint256 amount) internal override {}
  function _harvest() internal override {}
  function _migrate(address receiver) internal override {}
  function _processUnlock() internal override {}

  function token() external pure returns (address) {
    return address(0x1234123412341234);
  }
}
