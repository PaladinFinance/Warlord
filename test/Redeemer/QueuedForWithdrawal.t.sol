pragma solidity 0.8.16;
//SPDX-License-Identifier: MIT

import "./RedeemerTest.sol";

contract QueueForWithdrawal is RedeemerTest {
  address otherToken = makeAddr("otherToken");
  DummyLocker otherLocker;

  function setUp() public virtual override {
    RedeemerTest.setUp();
  }

  function _getCvxIndex(WarRedeemer.TokenWeight[] memory tokenWeights) internal pure returns (uint256) {
    for (uint256 i; i < tokenWeights.length; i++) {
      if (tokenWeights[i].token == address(cvx)) {
        return i;
      }
    }
    require(false, "Something went wrong");
    return 0;
  }

  function _getAuraIndex(WarRedeemer.TokenWeight[] memory tokenWeights) internal pure returns (uint256) {
    for (uint256 i; i < tokenWeights.length; i++) {
      if (tokenWeights[i].token == address(aura)) {
        return i;
      }
    }
    require(false, "Something went wrong");
    return 0;
  }

  function testJoiningQueue(uint256 amount) public {
    vm.assume(amount <= 1000e18);
    vm.assume(amount > 1e9);

    uint256 prevCvxQueued = redeemer.queuedForWithdrawal(address(cvx));
    uint256 prevAuraQueued = redeemer.queuedForWithdrawal(address(aura));

    WarRedeemer.TokenWeight[] memory tokenWeights = redeemer.getTokenWeights();
    uint256 cvxWeight = tokenWeights[_getCvxIndex(tokenWeights)].weight;
    uint256 auraWeight = tokenWeights[_getAuraIndex(tokenWeights)].weight;

    uint256 expectedFeeAmount = (amount * redeemer.redeemFee()) / 10_000;
    uint256 redeemCvxAmount = ratios.getBurnAmount(address(cvx), ((amount - expectedFeeAmount) * cvxWeight) / UNIT);
    uint256 redeemAuraAmount = ratios.getBurnAmount(address(aura), ((amount - expectedFeeAmount) * auraWeight) / UNIT);

    vm.startPrank(alice);
    war.approve(address(redeemer), amount);

    redeemer.joinQueue(amount);

    vm.stopPrank();

    assertEq(redeemer.queuedForWithdrawal(address(cvx)), prevCvxQueued + redeemCvxAmount);
    assertEq(redeemer.queuedForWithdrawal(address(aura)), prevAuraQueued + redeemAuraAmount);
  }

  function testJoiningQueueAndNotify(uint256 amount) public {
    // TODO Edge case with 9500000000000000001
    vm.assume(amount <= 100e18);
    vm.assume(amount > 1e9);

    uint256 redeemAmount = 1000e18;

    vm.startPrank(alice);
    war.approve(address(redeemer), redeemAmount);
    redeemer.joinQueue(redeemAmount);
    vm.stopPrank();

    uint256 prevQueued = redeemer.queuedForWithdrawal(address(cvx));

    vm.prank(address(cvxLocker));
    redeemer.notifyUnlock(address(cvx), amount);

    assertEq(redeemer.queuedForWithdrawal(address(cvx)), prevQueued - amount);
  }

  function testJoiningQueueAndNotifyAll() public {
    uint256 redeemAmount = 1000e18;

    vm.startPrank(alice);
    war.approve(address(redeemer), redeemAmount);
    redeemer.joinQueue(redeemAmount); // TODO naive correction
    vm.stopPrank();

    uint256 prevQueued = redeemer.queuedForWithdrawal(address(cvx));

    vm.prank(address(cvxLocker));
    redeemer.notifyUnlock(address(cvx), prevQueued);

    assertEq(redeemer.queuedForWithdrawal(address(cvx)), 0);
  }

  function testSuccessiveJoiningQueue(uint256 amount2, uint256 amount3) public {
    vm.assume(amount2 <= 100e18 && amount3 <= 100e18);
    vm.assume(amount2 > 1e9 && amount3 > 1e9);

    vm.prank(alice);
    war.transfer(bob, 150e18);

    uint256 amount = 100e18;

    uint256 prevCvxQueued = redeemer.queuedForWithdrawal(address(cvx));
    uint256 prevAuraQueued = redeemer.queuedForWithdrawal(address(aura));

    WarRedeemer.TokenWeight[] memory tokenWeights = redeemer.getTokenWeights();

    uint256 totalCvxIncrease;
    uint256 totalAuraIncrease;

    totalCvxIncrease += ratios.getBurnAmount(
      address(cvx),
      ((amount - ((amount * redeemer.redeemFee()) / 10_000)) * tokenWeights[_getCvxIndex(tokenWeights)].weight) / UNIT
    );
    totalAuraIncrease += ratios.getBurnAmount(
      address(aura),
      ((amount - ((amount * redeemer.redeemFee()) / 10_000)) * tokenWeights[_getAuraIndex(tokenWeights)].weight) / UNIT
    );

    totalCvxIncrease += ratios.getBurnAmount(
      address(cvx),
      ((amount2 - ((amount2 * redeemer.redeemFee()) / 10_000)) * tokenWeights[_getCvxIndex(tokenWeights)].weight) / UNIT
    );
    totalAuraIncrease += ratios.getBurnAmount(
      address(aura),
      ((amount2 - ((amount2 * redeemer.redeemFee()) / 10_000)) * tokenWeights[_getAuraIndex(tokenWeights)].weight)
        / UNIT
    );

    totalCvxIncrease += ratios.getBurnAmount(
      address(cvx),
      ((amount3 - ((amount3 * redeemer.redeemFee()) / 10_000)) * tokenWeights[_getCvxIndex(tokenWeights)].weight) / UNIT
    );
    totalAuraIncrease += ratios.getBurnAmount(
      address(aura),
      ((amount3 - ((amount3 * redeemer.redeemFee()) / 10_000)) * tokenWeights[_getAuraIndex(tokenWeights)].weight)
        / UNIT
    );

    vm.startPrank(alice);
    war.approve(address(redeemer), type(uint256).max);
    redeemer.joinQueue(amount);
    vm.stopPrank();

    vm.startPrank(bob);
    war.approve(address(redeemer), type(uint256).max);
    redeemer.joinQueue(amount2);
    vm.stopPrank();

    vm.startPrank(alice);
    redeemer.joinQueue(amount3);
    vm.stopPrank();

    assertEq(redeemer.queuedForWithdrawal(address(cvx)), prevCvxQueued + totalCvxIncrease);
    assertEq(redeemer.queuedForWithdrawal(address(aura)), prevAuraQueued + totalAuraIncrease);
  }
}
