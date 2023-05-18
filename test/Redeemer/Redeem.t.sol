pragma solidity 0.8.16;
//SPDX-License-Identifier: MIT

import "./RedeemerTest.sol";

contract Redeem is RedeemerTest {
  function setUp() public virtual override {
    RedeemerTest.setUp();

    uint256 warAmount = 500e18;

    vm.startPrank(alice);
    war.approve(address(redeemer), warAmount);
    redeemer.joinQueue(warAmount);
    vm.stopPrank();
  }

  function _getUserCvxTicketsIndexes(WarRedeemer.RedeemTicket[] memory userTickets) internal pure returns(uint256[] memory) {
    uint256 nbTickets = 0;
    for(uint256 i; i < userTickets.length; i++) {
      if(userTickets[i].token == address(cvx)) {
        nbTickets++;
      }
    }
    uint256[] memory indexes = new uint256[](nbTickets);
    uint256 j;
    for(uint256 i; i < userTickets.length; i++) {
      if(userTickets[i].token == address(cvx)) {
        indexes[j] = i;
        j++;
      }
    }
    return indexes;
  }

  function testDefaultBehavior() public {
    WarRedeemer.RedeemTicket[] memory userTickets = redeemer.getUserRedeemTickets(alice);
    uint256[] memory cvxTicketsIds = _getUserCvxTicketsIndexes(userTickets);
    WarRedeemer.RedeemTicket memory ticket = userTickets[cvxTicketsIds[0]];

    uint256[] memory tickets = new uint256[](1);
    tickets[0] = ticket.id;

    uint256 neededAmount = redeemer.queuedForWithdrawal(address(cvx));

    vm.prank(admin);
    cvx.transfer(address(redeemer), neededAmount);

    vm.prank(address(cvxLocker));
    redeemer.notifyUnlock(address(cvx), neededAmount);

    uint256 prevReceiverBalance = cvx.balanceOf(alice);
    uint256 prevRedeemerBalance = cvx.balanceOf(address(redeemer));

    vm.startPrank(alice);

    vm.expectEmit(true, true, true, true);
    emit Redeemed(address(cvx), alice, alice, ticket.id);

    redeemer.redeem(tickets, alice);

    vm.stopPrank();

    assertEq(cvx.balanceOf(alice), prevReceiverBalance + ticket.amount);
    assertEq(cvx.balanceOf(address(redeemer)), prevRedeemerBalance - ticket.amount);

    (,,,, bool isTicketRedeemed) = redeemer.userRedeems(alice, ticket.id);
    assertEq(isTicketRedeemed, true);
  }

  function testReddemMultipleTickets() public {
    uint256 warAmount2 = 75e18;

    vm.startPrank(alice);
    war.approve(address(redeemer), warAmount2);
    redeemer.joinQueue(warAmount2); // TODO naive correction
    vm.stopPrank();

    WarRedeemer.RedeemTicket[] memory userTickets = redeemer.getUserRedeemTickets(alice);
    uint256[] memory cvxTicketsIds = _getUserCvxTicketsIndexes(userTickets);
    WarRedeemer.RedeemTicket memory ticket1 = userTickets[cvxTicketsIds[0]];
    WarRedeemer.RedeemTicket memory ticket2 = userTickets[cvxTicketsIds[1]];

    uint256[] memory tickets = new uint256[](2);
    tickets[0] = ticket1.id;
    tickets[1] = ticket2.id;

    uint256 neededAmount = redeemer.queuedForWithdrawal(address(cvx));

    vm.prank(admin);
    cvx.transfer(address(redeemer), neededAmount);

    vm.prank(address(cvxLocker));
    redeemer.notifyUnlock(address(cvx), neededAmount);

    uint256 prevReceiverBalance = cvx.balanceOf(alice);
    uint256 prevRedeemerBalance = cvx.balanceOf(address(redeemer));

    vm.startPrank(alice);

    vm.expectEmit(true, true, true, true);
    emit Redeemed(address(cvx), alice, alice, ticket1.id);

    vm.expectEmit(true, true, true, true);
    emit Redeemed(address(cvx), alice, alice, ticket2.id);

    redeemer.redeem(tickets, alice);

    vm.stopPrank();

    uint256 totalRedeemed = ticket1.amount + ticket2.amount;

    assertEq(cvx.balanceOf(alice), prevReceiverBalance + totalRedeemed);
    assertEq(cvx.balanceOf(address(redeemer)), prevRedeemerBalance - totalRedeemed);

    (,,,, bool isTicket1Redeemed) = redeemer.userRedeems(alice, ticket1.id);
    assertEq(isTicket1Redeemed, true);

    (,,,, bool isTicket2Redeemed) = redeemer.userRedeems(alice, ticket2.id);
    assertEq(isTicket2Redeemed, true);
  }

  function testReddemMultipleTicketsWithUserInbetween() public {
    vm.prank(alice);
    war.transfer(bob, 150e18);

    uint256 warAmount2 = 150e18;
    uint256 warAmount3 = 75e18;

    vm.startPrank(bob);
    war.approve(address(redeemer), warAmount2);
    redeemer.joinQueue(warAmount2);
    vm.stopPrank();

    vm.startPrank(alice);
    war.approve(address(redeemer), warAmount3);
    redeemer.joinQueue(warAmount3);
    vm.stopPrank();

    WarRedeemer.RedeemTicket[] memory userTickets = redeemer.getUserRedeemTickets(alice);
    uint256[] memory cvxTicketsIds = _getUserCvxTicketsIndexes(userTickets);
    WarRedeemer.RedeemTicket memory ticket1 = userTickets[cvxTicketsIds[0]];
    WarRedeemer.RedeemTicket memory ticket2 = userTickets[cvxTicketsIds[1]];

    uint256[] memory tickets = new uint256[](2);
    tickets[0] = ticket1.id;
    tickets[1] = ticket2.id;

    uint256 neededAmount = redeemer.queuedForWithdrawal(address(cvx));

    vm.prank(admin);
    cvx.transfer(address(redeemer), neededAmount);

    vm.prank(address(cvxLocker));
    redeemer.notifyUnlock(address(cvx), neededAmount);

    uint256 prevReceiverBalance = cvx.balanceOf(alice);
    uint256 prevRedeemerBalance = cvx.balanceOf(address(redeemer));

    vm.startPrank(alice);

    vm.expectEmit(true, true, true, true);
    emit Redeemed(address(cvx), alice, alice, ticket1.id);

    vm.expectEmit(true, true, true, true);
    emit Redeemed(address(cvx), alice, alice, ticket2.id);

    redeemer.redeem(tickets, alice);

    vm.stopPrank();

    uint256 totalRedeemed = ticket1.amount + ticket2.amount;

    assertEq(cvx.balanceOf(alice), prevReceiverBalance + totalRedeemed);
    assertEq(cvx.balanceOf(address(redeemer)), prevRedeemerBalance - totalRedeemed);

    (,,,, bool isTicket1Redeemed) = redeemer.userRedeems(alice, ticket1.id);
    assertEq(isTicket1Redeemed, true);

    (,,,, bool isTicket2Redeemed) = redeemer.userRedeems(alice, ticket2.id);
    assertEq(isTicket2Redeemed, true);
  }

  function testInvalidTicketId() public {
    WarRedeemer.RedeemTicket[] memory userTickets = redeemer.getUserRedeemTickets(alice);
    uint256[] memory cvxTicketsIds = _getUserCvxTicketsIndexes(userTickets);
    WarRedeemer.RedeemTicket memory ticket = userTickets[cvxTicketsIds[0]];

    uint256[] memory tickets = new uint256[](1);
    tickets[0] = ticket.id + 2;

    uint256 neededAmount = redeemer.queuedForWithdrawal(address(cvx));

    vm.prank(admin);
    cvx.transfer(address(redeemer), neededAmount);

    vm.prank(address(cvxLocker));
    redeemer.notifyUnlock(address(cvx), neededAmount);

    vm.startPrank(alice);

    vm.expectRevert(Errors.InvalidIndex.selector);
    redeemer.redeem(tickets, alice);

    vm.stopPrank();
  }

  function testCannotRedeemYet1() public {
    WarRedeemer.RedeemTicket[] memory userTickets = redeemer.getUserRedeemTickets(alice);
    uint256[] memory cvxTicketsIds = _getUserCvxTicketsIndexes(userTickets);
    WarRedeemer.RedeemTicket memory ticket = userTickets[cvxTicketsIds[0]];

    uint256[] memory tickets = new uint256[](1);
    tickets[0] = ticket.id;

    vm.startPrank(alice);

    vm.expectRevert(Errors.CannotRedeemYet.selector);
    redeemer.redeem(tickets, alice);

    vm.stopPrank();
  }

  function testCannotRedeemYet2() public {
    WarRedeemer.RedeemTicket[] memory userTickets = redeemer.getUserRedeemTickets(alice);
    uint256[] memory cvxTicketsIds = _getUserCvxTicketsIndexes(userTickets);
    WarRedeemer.RedeemTicket memory ticket = userTickets[cvxTicketsIds[0]];

    uint256[] memory tickets = new uint256[](1);
    tickets[0] = ticket.id;

    uint256 notifyAmount = (redeemer.queuedForWithdrawal(address(cvx)) / 2);

    vm.prank(admin);
    cvx.transfer(address(redeemer), notifyAmount);

    vm.prank(address(cvxLocker));
    redeemer.notifyUnlock(address(cvx), notifyAmount);

    vm.startPrank(alice);

    vm.expectRevert(Errors.CannotRedeemYet.selector);
    redeemer.redeem(tickets, alice);

    vm.stopPrank();
  }

  function testAlreadyRedeemed() public {
    WarRedeemer.RedeemTicket[] memory userTickets = redeemer.getUserRedeemTickets(alice);
    uint256[] memory cvxTicketsIds = _getUserCvxTicketsIndexes(userTickets);
    WarRedeemer.RedeemTicket memory ticket = userTickets[cvxTicketsIds[0]];

    uint256[] memory tickets = new uint256[](1);
    tickets[0] = ticket.id;

    uint256 neededAmount = redeemer.queuedForWithdrawal(address(cvx));

    vm.prank(admin);
    cvx.transfer(address(redeemer), neededAmount);

    vm.prank(address(cvxLocker));
    redeemer.notifyUnlock(address(cvx), neededAmount);

    vm.prank(alice);
    redeemer.redeem(tickets, alice);

    vm.startPrank(alice);

    vm.expectRevert(Errors.AlreadyRedeemed.selector);
    redeemer.redeem(tickets, alice);

    vm.stopPrank();
  }

  function testEmptyArray() public {
    uint256[] memory tickets = new uint256[](0);

    uint256 neededAmount = redeemer.queuedForWithdrawal(address(cvx));

    vm.prank(admin);
    cvx.transfer(address(redeemer), neededAmount);
    vm.prank(address(cvxLocker));
    redeemer.notifyUnlock(address(cvx), neededAmount);

    vm.startPrank(alice);

    vm.expectRevert(Errors.EmptyArray.selector);
    redeemer.redeem(tickets, alice);

    vm.stopPrank();
  }

  function testZeroAddressReceiver() public {
    WarRedeemer.RedeemTicket[] memory userTickets = redeemer.getUserRedeemTickets(alice);
    uint256[] memory cvxTicketsIds = _getUserCvxTicketsIndexes(userTickets);
    WarRedeemer.RedeemTicket memory ticket = userTickets[cvxTicketsIds[0]];

    uint256[] memory tickets = new uint256[](1);
    tickets[0] = ticket.id;

    uint256 neededAmount = redeemer.queuedForWithdrawal(address(cvx));

    vm.prank(admin);
    cvx.transfer(address(redeemer), neededAmount);

    vm.prank(address(cvxLocker));
    redeemer.notifyUnlock(address(cvx), neededAmount);

    vm.startPrank(alice);

    vm.expectRevert(Errors.ZeroAddress.selector);
    redeemer.redeem(tickets, address(0));

    vm.stopPrank();
  }

  function testWhenNotPaused() public {
    WarRedeemer.RedeemTicket[] memory userTickets = redeemer.getUserRedeemTickets(alice);
    uint256[] memory cvxTicketsIds = _getUserCvxTicketsIndexes(userTickets);
    WarRedeemer.RedeemTicket memory ticket = userTickets[cvxTicketsIds[0]];

    uint256[] memory tickets = new uint256[](1);
    tickets[0] = ticket.id;

    uint256 neededAmount = redeemer.queuedForWithdrawal(address(cvx));

    vm.prank(admin);
    cvx.transfer(address(redeemer), neededAmount);

    vm.prank(address(cvxLocker));
    redeemer.notifyUnlock(address(cvx), neededAmount);

    vm.prank(admin);
    redeemer.pause();

    vm.startPrank(alice);

    vm.expectRevert("Pausable: paused");
    redeemer.redeem(tickets, alice);

    vm.stopPrank();
  }
}
