pragma solidity 0.8.16;
//SPDX-License-Identifier: MIT

import "./RedeemerTest.sol";

contract GetUserActiveRedeemTickets is RedeemerTest {
  function setUp() public virtual override {
    RedeemerTest.setUp();

    vm.startPrank(_minter);
    war.mint(alice, 1000e18);
    vm.stopPrank();

    address[] memory tokens = new address[](1);
    tokens[0] = address(cvx);
    uint256[] memory weights = new uint256[](1);
    weights[0] = 10_000;

    uint256 warAmount = 100e18;
    uint256 warAmount2 = 75e18;
    uint256 warAmount3 = 150e18;

    vm.prank(alice);
    war.approve(address(redeemer), type(uint256).max);

    vm.prank(alice);
    redeemer.joinQueue(tokens, weights, warAmount);

    uint256 neededAmount = redeemer.queuedForWithdrawal(address(cvx));

    vm.prank(admin);
    cvx.transfer(address(redeemer), neededAmount);

    vm.prank(address(cvxLocker));
    redeemer.notifyUnlock(address(cvx), neededAmount);

    vm.prank(alice);
    redeemer.joinQueue(tokens, weights, warAmount2);

    vm.prank(alice);
    redeemer.joinQueue(tokens, weights, warAmount3);
  }

  function testDefaultBehavior() public {
    WarRedeemer.RedeemTicket[] memory userTickets = redeemer.getUserRedeemTickets(alice);
    WarRedeemer.RedeemTicket[] memory prevUserActiveTickets = redeemer.getUserActiveRedeemTickets(alice);

    for (uint256 i; i < prevUserActiveTickets.length; i++) {
      assertEq(prevUserActiveTickets[i].id, userTickets[i].id);
      assertEq(prevUserActiveTickets[i].token, userTickets[i].token);
      assertEq(prevUserActiveTickets[i].amount, userTickets[i].amount);
      assertEq(prevUserActiveTickets[i].redeemIndex, userTickets[i].redeemIndex);
      assertEq(prevUserActiveTickets[i].redeemed, false);
    }

    WarRedeemer.RedeemTicket memory redeemedTicket = userTickets[0];
    uint256[] memory tickets = new uint256[](1);
    tickets[0] = redeemedTicket.id;

    vm.prank(alice);
    redeemer.redeem(tickets, alice);

    WarRedeemer.RedeemTicket[] memory userActiveTickets = redeemer.getUserActiveRedeemTickets(alice);

    // Since Ticket ID 0 was redeemed, not active anymore
    for (uint256 i; i < userActiveTickets.length; i++) {
      assertEq(userActiveTickets[i].id == redeemedTicket.id, false);

      assertEq(userActiveTickets[i].id, userTickets[i + 1].id);
      assertEq(userActiveTickets[i].token, userTickets[i + 1].token);
      assertEq(userActiveTickets[i].amount, userTickets[i + 1].amount);
      assertEq(userActiveTickets[i].redeemIndex, userTickets[i + 1].redeemIndex);
      assertEq(userActiveTickets[i].redeemed, false);
    }
  }
}
