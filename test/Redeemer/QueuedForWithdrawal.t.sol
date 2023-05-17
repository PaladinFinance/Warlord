pragma solidity 0.8.16;
//SPDX-License-Identifier: MIT

import "./RedeemerTest.sol";

contract QueueForWithdrawal is RedeemerTest {
  address otherToken = makeAddr("otherToken");
  DummyLocker otherLocker;

  function setUp() public virtual override {
    RedeemerTest.setUp();

    otherLocker = new DummyLocker(otherToken);

    vm.startPrank(admin);
    redeemer.setLocker(otherToken, address(otherLocker));
    ratios.addTokenWithSupply(otherToken, 1_000_000e18);
    vm.stopPrank();

    vm.startPrank(_minter);
    war.mint(alice, 1000e18);
    vm.stopPrank();
  }

  function testJoiningQueue(uint256 amount) public {
    vm.assume(amount <= 1000e18);
    vm.assume(amount > 1e9);

    address[] memory tokens = new address[](1);
    tokens[0] = address(cvx);
    uint256[] memory weights = new uint256[](1);
    weights[0] = 10_000;

    uint256 prevQueued = redeemer.queuedForWithdrawal(address(cvx));

    uint256 expectedFeeAmount = (amount * redeemer.redeemFee()) / 10_000;
    uint256 burnAmount = ((amount - expectedFeeAmount) * 10_000) / 10_000;
    uint256 redeemAmount = ratios.getBurnAmount(address(cvx), burnAmount);

    vm.startPrank(alice);
    war.approve(address(redeemer), amount);

    redeemer.joinQueue(amount); // TODO naive correction

    vm.stopPrank();

    assertEq(redeemer.queuedForWithdrawal(address(cvx)), prevQueued + redeemAmount);
  }

  function testJoiningQueueAndNotify(uint256 amount) public {
    // TODO Edge case with 9500000000000000001
    vm.assume(amount <= 100e18);
    vm.assume(amount > 1e9);

    address[] memory tokens = new address[](1);
    tokens[0] = otherToken;
    uint256[] memory weights = new uint256[](1);
    weights[0] = 10_000;

    uint256 redeemAmount = 1000e18;

    vm.startPrank(alice);
    war.approve(address(redeemer), redeemAmount);
    redeemer.joinQueue(amount); // TODO naive correction
    vm.stopPrank();

    uint256 prevQueued = redeemer.queuedForWithdrawal(otherToken);

    vm.prank(address(otherLocker));
    redeemer.notifyUnlock(address(otherToken), amount);

    assertEq(redeemer.queuedForWithdrawal(address(otherToken)), prevQueued - amount);
  }

  function testJoiningQueueAndNotifyAll() public {
    address[] memory tokens = new address[](1);
    tokens[0] = otherToken;
    uint256[] memory weights = new uint256[](1);
    weights[0] = 10_000;

    uint256 redeemAmount = 1000e18;

    vm.startPrank(alice);
    war.approve(address(redeemer), redeemAmount);
    redeemer.joinQueue(redeemAmount); // TODO naive correction
    vm.stopPrank();

    uint256 prevQueued = redeemer.queuedForWithdrawal(otherToken);

    vm.prank(address(otherLocker));
    redeemer.notifyUnlock(address(otherToken), prevQueued);

    assertEq(redeemer.queuedForWithdrawal(address(otherToken)), 0);
  }
}
