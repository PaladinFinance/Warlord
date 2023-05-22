pragma solidity 0.8.16;
//SPDX-License-Identifier: MIT

import "./RedeemerTest.sol";

contract GetUserActiveRedeemTickets is RedeemerTest {
  function setUp() public virtual override {
    RedeemerTest.setUp();

    uint256 warAmount = 100e18;
    uint256 warAmount2 = 75e18;

    vm.prank(alice);
    war.approve(address(redeemer), type(uint256).max);

    vm.prank(alice);
    redeemer.joinQueue(warAmount);

    uint256 neededCvxAmount = redeemer.queuedForWithdrawal(address(cvx));

    vm.prank(admin);
    cvx.transfer(address(redeemer), neededCvxAmount);

    vm.prank(address(cvxLocker));
    redeemer.notifyUnlock(address(cvx), neededCvxAmount);

    vm.prank(alice);
    redeemer.joinQueue(warAmount2);
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

    uint256 redeemTicketIndex = userTickets[0].token == address(cvx) ? 0 : 1;
    WarRedeemer.RedeemTicket memory redeemedTicket = userTickets[redeemTicketIndex];
    uint256[] memory tickets = new uint256[](1);
    tickets[0] = redeemedTicket.id;

    vm.prank(alice);
    redeemer.redeem(tickets, alice);

    WarRedeemer.RedeemTicket[] memory userActiveTickets = redeemer.getUserActiveRedeemTickets(alice);

    uint256 j;
    for (uint256 i; i < userActiveTickets.length; i++) {
      if (userTickets[j].id == redeemedTicket.id) {
        unchecked {
          j++;
        }
      }

      assertEq(userActiveTickets[i].id == redeemedTicket.id, false);

      assertEq(userActiveTickets[i].id, userTickets[j].id);
      assertEq(userActiveTickets[i].token, userTickets[j].token);
      assertEq(userActiveTickets[i].amount, userTickets[j].amount);
      assertEq(userActiveTickets[i].redeemIndex, userTickets[j].redeemIndex);
      assertEq(userActiveTickets[i].redeemed, false);

      unchecked {
        j++;
      }
    }
  }
}
