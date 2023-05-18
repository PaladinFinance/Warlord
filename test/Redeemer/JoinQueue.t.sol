pragma solidity 0.8.16;
//SPDX-License-Identifier: MIT

import "./RedeemerTest.sol";

contract JoinQueue is RedeemerTest {
  function setUp() public virtual override {
    RedeemerTest.setUp();

    vm.prank(alice);
    war.approve(address(redeemer), type(uint256).max);
  }

  function testDefaultBehaviorBurn(uint256 amount) public {
    vm.assume(amount <= 1000e18);
    vm.assume(amount > 1e9);

    uint256 prevWarBalance = war.balanceOf(alice);
    uint256 prevWarBalanceFee = war.balanceOf(redemptionFeeReceiver);
    uint256 prevWarSupply = war.totalSupply();

    uint256 expectedFeeAmount = (amount * redeemer.redeemFee()) / 10_000;

    assertGt(war.balanceOf(alice), amount);

    vm.prank(alice);
    redeemer.joinQueue(amount);

    assertEq(war.balanceOf(alice), prevWarBalance - amount);
    assertEq(war.balanceOf(redemptionFeeReceiver), prevWarBalanceFee + expectedFeeAmount);
    assertEq(war.totalSupply(), prevWarSupply - (amount - expectedFeeAmount));
  }

  function _getTokenIndexes(
    WarRedeemer.TokenWeight[] memory tokenWeights
  ) internal pure returns(uint256, uint256) {
    bool isCvxFirst = tokenWeights[0].token == address(cvx);
    uint256 cvxIndex = isCvxFirst ? 0 : 1;
    uint256 auraIndex = isCvxFirst ? 1 : 0;

    return (cvxIndex, auraIndex);
  }

  function _getTicketIndexes(
    WarRedeemer.TokenWeight[] memory tokenWeights,
    uint256 userRedeemTicketsLength,
    uint256 redeemAmountCvx,
    uint256 redeemAmountAura
  ) internal pure returns(uint256, uint256) {
    bool isCvxFirst = tokenWeights[0].token == address(cvx);
    
    // Can be done better
    uint256 cvxTicketIndex;
    uint256 auraTicketIndex;
    if(isCvxFirst) {
      cvxTicketIndex = userRedeemTicketsLength;
      auraTicketIndex = redeemAmountCvx > 0 ? userRedeemTicketsLength + 1 : userRedeemTicketsLength;
    } else {
      auraTicketIndex = userRedeemTicketsLength;
      cvxTicketIndex = redeemAmountAura > 0 ? userRedeemTicketsLength + 1 : userRedeemTicketsLength;
    }

    return (cvxTicketIndex, auraTicketIndex);
  }

  function testDefaultBehaviorTickets(uint256 amount) public {
    vm.assume(amount <= 1000e18);
    vm.assume(amount > 1e9);

    WarRedeemer.TokenWeight[] memory tokenWeights = redeemer.getTokenWeights();
    (uint256 cvxIndex, uint256 auraIndex) = _getTokenIndexes(tokenWeights);

    uint256 userRedeemTicketsLength = (redeemer.getUserRedeemTickets(alice)).length;

    (uint256 prevCvxQueueIndex,) = redeemer.tokenIndexes(address(cvx));
    (uint256 prevAuraQueueIndex,) = redeemer.tokenIndexes(address(aura));

    uint256 expectedFeeAmount = (amount * redeemer.redeemFee()) / 10_000;

    uint256 redeemAmountCvx = ratios.getBurnAmount(address(cvx), ((amount - expectedFeeAmount) * tokenWeights[cvxIndex].weight) / UNIT);
    uint256 redeemAmountAura = ratios.getBurnAmount(address(aura), ((amount - expectedFeeAmount) * tokenWeights[auraIndex].weight) / UNIT);

    (uint256 cvxTicketIndex, uint256 auraTicketIndex) = _getTicketIndexes(tokenWeights, userRedeemTicketsLength, redeemAmountCvx, redeemAmountAura);

    vm.startPrank(alice);
    if (redeemAmountAura > 0) {
      vm.expectEmit(true, true, false, true);
      emit NewRedeemTicket(
        address(aura), alice, auraTicketIndex, redeemAmountAura, prevAuraQueueIndex + redeemAmountAura
      );
    }
    if (redeemAmountCvx > 0) {
      vm.expectEmit(true, true, false, true);
      emit NewRedeemTicket(
        address(cvx), alice, cvxTicketIndex, redeemAmountCvx, prevCvxQueueIndex + redeemAmountCvx
      );
    }

    redeemer.joinQueue(amount);

    vm.stopPrank();

    (uint256 newCvxQueueIndex,) = redeemer.tokenIndexes(address(cvx));
    (uint256 newAuraQueueIndex,) = redeemer.tokenIndexes(address(aura));

    WarRedeemer.RedeemTicket[] memory userRedeemTickets = redeemer.getUserRedeemTickets(alice);
    uint256 newUserRedeemTicketsLength =
      redeemAmountCvx > 0 && redeemAmountAura > 0 ? userRedeemTicketsLength + 2 : userRedeemTicketsLength + 1;

    assertEq(userRedeemTickets.length, newUserRedeemTicketsLength);

    if (redeemAmountCvx > 0) {
      assertEq(newCvxQueueIndex, prevCvxQueueIndex + redeemAmountCvx);

      WarRedeemer.RedeemTicket memory newCvxTicket = userRedeemTickets[cvxTicketIndex];
      assertEq(newCvxTicket.id, cvxTicketIndex);
      assertEq(newCvxTicket.token, address(cvx));
      assertEq(newCvxTicket.amount, redeemAmountCvx);
      assertEq(newCvxTicket.redeemIndex, newCvxQueueIndex);
      assertEq(newCvxTicket.redeemed, false);
    } else {
      assertEq(newCvxQueueIndex, prevCvxQueueIndex);
    }

    if (redeemAmountAura > 0) {
      assertEq(newAuraQueueIndex, prevAuraQueueIndex + redeemAmountAura);

      WarRedeemer.RedeemTicket memory newAuraTicket = userRedeemTickets[auraTicketIndex];
      assertEq(newAuraTicket.id, auraTicketIndex);
      assertEq(newAuraTicket.token, address(aura));
      assertEq(newAuraTicket.amount, redeemAmountAura);
      assertEq(newAuraTicket.redeemIndex, newAuraQueueIndex);
      assertEq(newAuraTicket.redeemed, false);
    } else {
      assertEq(newAuraQueueIndex, prevAuraQueueIndex);
    }
  }

  function _extraDepostits(uint256 extraCvxDeposit, uint256 extraAuraDeposit) internal {
    address[] memory lockers;
    uint256[] memory amounts;

    if(extraCvxDeposit > 0 && extraAuraDeposit > 0) {
      lockers = new address[](2);
      lockers[0] = address(cvx);
      lockers[1] = address(aura);
      amounts = new uint256[](2);
      amounts[0] = extraCvxDeposit;
      amounts[1] = extraAuraDeposit;
    } else if(extraCvxDeposit > 0) {
      lockers = new address[](1);
      lockers[0] = address(cvx);
      amounts = new uint256[](1);
      amounts[0] = extraCvxDeposit;
    } else {
      lockers = new address[](1);
      lockers[0] = address(aura);
      amounts = new uint256[](1);
      amounts[0] = extraAuraDeposit;
    }

    vm.startPrank(admin);
    cvx.approve(address(minter), type(uint256).max);
    aura.approve(address(minter), type(uint256).max);

    minter.mintMultiple(lockers, amounts, bob);
    vm.stopPrank();

  }

  struct TestVars {
    uint256 cvxIndex;
    uint256 auraIndex;
    uint256 userRedeemTicketsLength;
    uint256 prevCvxQueueIndex;
    uint256 prevAuraQueueIndex;
    uint256 expectedFeeAmount;
    uint256 redeemAmountCvx;
    uint256 redeemAmountAura;
    uint256 cvxTicketIndex;
    uint256 auraTicketIndex;
  }

  function testTicketsWithDifferentWeights(
    uint256 amount,
    uint256 extraCvxDeposit,
    uint256 extraAuraDeposit
  ) public {
    vm.assume(amount <= 1000e18);
    vm.assume(amount > 1e9);
    vm.assume(extraCvxDeposit <= 5_000e18);
    vm.assume(extraAuraDeposit <= 5_000e18);
    vm.assume(extraCvxDeposit > 1e4 && extraAuraDeposit > 1e4);

    TestVars memory vars;

    _extraDepostits(extraCvxDeposit, extraAuraDeposit);

    WarRedeemer.TokenWeight[] memory tokenWeights = redeemer.getTokenWeights();
    (vars.cvxIndex, vars.auraIndex) = _getTokenIndexes(tokenWeights);

    vars.userRedeemTicketsLength = (redeemer.getUserRedeemTickets(alice)).length;

    (vars.prevCvxQueueIndex,) = redeemer.tokenIndexes(address(cvx));
    (vars.prevAuraQueueIndex,) = redeemer.tokenIndexes(address(aura));

    vars.expectedFeeAmount = (amount * redeemer.redeemFee()) / 10_000;

    vars.redeemAmountCvx = ratios.getBurnAmount(address(cvx), ((amount - vars.expectedFeeAmount) * tokenWeights[vars.cvxIndex].weight) / UNIT);
    vars.redeemAmountAura = ratios.getBurnAmount(address(aura), ((amount - vars.expectedFeeAmount) * tokenWeights[vars.auraIndex].weight) / UNIT);

    (vars.cvxTicketIndex, vars.auraTicketIndex) = _getTicketIndexes(tokenWeights, vars.userRedeemTicketsLength, vars.redeemAmountCvx, vars.redeemAmountAura);

    vm.startPrank(alice);
    if (vars.redeemAmountAura > 0) {
      vm.expectEmit(true, true, false, true);
      emit NewRedeemTicket(
        address(aura), alice, vars.auraTicketIndex, vars.redeemAmountAura, vars.prevAuraQueueIndex + vars.redeemAmountAura
      );
    }
    if (vars.redeemAmountCvx > 0) {
      vm.expectEmit(true, true, false, true);
      emit NewRedeemTicket(
        address(cvx), alice, vars.cvxTicketIndex, vars.redeemAmountCvx, vars.prevCvxQueueIndex + vars.redeemAmountCvx
      );
    }

    redeemer.joinQueue(amount);

    vm.stopPrank();

    (uint256 newCvxQueueIndex,) = redeemer.tokenIndexes(address(cvx));
    (uint256 newAuraQueueIndex,) = redeemer.tokenIndexes(address(aura));

    WarRedeemer.RedeemTicket[] memory userRedeemTickets = redeemer.getUserRedeemTickets(alice);
    uint256 newUserRedeemTicketsLength =
      vars.redeemAmountCvx > 0 && vars.redeemAmountAura > 0 ? vars.userRedeemTicketsLength + 2 : vars.userRedeemTicketsLength + 1;

    assertEq(userRedeemTickets.length, newUserRedeemTicketsLength);

    if (vars.redeemAmountCvx > 0) {
      assertEq(newCvxQueueIndex, vars.prevCvxQueueIndex + vars.redeemAmountCvx);

      WarRedeemer.RedeemTicket memory newCvxTicket = userRedeemTickets[vars.cvxTicketIndex];
      assertEq(newCvxTicket.id, vars.cvxTicketIndex);
      assertEq(newCvxTicket.token, address(cvx));
      assertEq(newCvxTicket.amount, vars.redeemAmountCvx);
      assertEq(newCvxTicket.redeemIndex, newCvxQueueIndex);
      assertEq(newCvxTicket.redeemed, false);
    } else {
      assertEq(newCvxQueueIndex, vars.prevCvxQueueIndex);
    }

    if (vars.redeemAmountAura > 0) {
      assertEq(newAuraQueueIndex, vars.prevAuraQueueIndex + vars.redeemAmountAura);

      WarRedeemer.RedeemTicket memory newAuraTicket = userRedeemTickets[vars.auraTicketIndex];
      assertEq(newAuraTicket.id, vars.auraTicketIndex);
      assertEq(newAuraTicket.token, address(aura));
      assertEq(newAuraTicket.amount, vars.redeemAmountAura);
      assertEq(newAuraTicket.redeemIndex, newAuraQueueIndex);
      assertEq(newAuraTicket.redeemed, false);
    } else {
      assertEq(newAuraQueueIndex, vars.prevAuraQueueIndex);
    }
  }


  function testZeroAmount() public {
    vm.startPrank(alice);

    vm.expectRevert(Errors.ZeroValue.selector);
    redeemer.joinQueue(0);

    vm.stopPrank();
  }

  function testWhenNotPaused(uint256 amount) public {
    vm.prank(admin);
    redeemer.pause();

    vm.expectRevert("Pausable: paused");

    redeemer.joinQueue(amount);
  }
}
