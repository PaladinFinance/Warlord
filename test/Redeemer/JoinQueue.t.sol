pragma solidity 0.8.16;
//SPDX-License-Identifier: MIT

import "./RedeemerTest.sol";

contract JoinQueue is RedeemerTest {
    function setUp() public virtual override {
        RedeemerTest.setUp();

        vm.startPrank(_minter);
        war.mint(alice, 1_000e18);
        vm.stopPrank();

        vm.prank(alice);
        war.approve(address(redeemer), type(uint256).max);
    }

    function testDefaultBehaviorBurn(uint256 weightCvx, uint256 amount) public {
        vm.assume(weightCvx < 10_000);
        vm.assume(amount <= 1_000e18);
        vm.assume(amount > 1e9);
        vm.assume(weightCvx > 0);
        
        uint256 weightAura = 10_000 - weightCvx;

        address[] memory tokens = new address[](2);
        tokens[0] = address(cvx);
        tokens[1] = address(aura);
        uint256[] memory weights = new uint256[](2);
        weights[0] = weightCvx;
        weights[1] = weightAura;

        uint256 prevWarBalance = war.balanceOf(alice);
        uint256 prevWarBalanceFee = war.balanceOf(redemptionFeeReceiver);
        uint256 prevWarSupply = war.totalSupply();

        uint256 expectedFeeAmount = (amount * redeemer.redeemFee()) / 10_000;

        vm.prank(alice);
        redeemer.joinQueue(tokens, weights, amount);

        assertEq(war.balanceOf(alice), prevWarBalance - amount);
        assertEq(war.balanceOf(redemptionFeeReceiver), prevWarBalanceFee + expectedFeeAmount);
        assertEq(war.totalSupply(), prevWarSupply - (amount - expectedFeeAmount));
    }

    function testDefaultBehaviorTickets(uint256 weightCvx, uint256 amount) public {
        vm.assume(weightCvx < 10_000);
        vm.assume(amount <= 1_000e18);
        vm.assume(amount > 1e9);
        vm.assume(weightCvx > 0);

        address[] memory tokens = new address[](2);
        tokens[0] = address(cvx);
        tokens[1] = address(aura);
        uint256[] memory weights = new uint256[](2);
        weights[0] = weightCvx;
        weights[1] = 10_000 - weightCvx;

        uint256 userRedeemTicketsLength = (redeemer.getUserRedeemTickets(alice)).length;

        (uint256 prevCvxQueueIndex,) = redeemer.tokenIndexes(address(cvx));
        (uint256 prevAuraQueueIndex,) = redeemer.tokenIndexes(address(aura));

        uint256 expectedFeeAmount = (amount * redeemer.redeemFee()) / 10_000;

        uint256 redeemAmountCvx = ratios.getBurnAmount(
            address(cvx),
            ((amount - expectedFeeAmount) * weightCvx) / 10_000
        );
        uint256 redeemAmountAura = ratios.getBurnAmount(
            address(aura),
            ((amount - expectedFeeAmount) * (10_000 - weightCvx)) / 10_000
        );

        uint256 cvxTicketIndex = userRedeemTicketsLength;
        uint256 auraTicketIndex = redeemAmountCvx > 0 ? userRedeemTicketsLength + 1 : userRedeemTicketsLength;

        vm.startPrank(alice);
        if(redeemAmountCvx > 0) {
            vm.expectEmit(true, true, false, true);
            emit NewRedeemTicket(address(cvx), alice, cvxTicketIndex, redeemAmountCvx, prevCvxQueueIndex + redeemAmountCvx);
        }
        

        if(redeemAmountAura > 0) {
            vm.expectEmit(true, true, false, true);
            emit NewRedeemTicket(address(aura), alice, auraTicketIndex, redeemAmountAura, prevAuraQueueIndex + redeemAmountAura);
        }

        redeemer.joinQueue(tokens, weights, amount);

        vm.stopPrank();

        (uint256 newCvxQueueIndex,) = redeemer.tokenIndexes(address(cvx));
        (uint256 newAuraQueueIndex,) = redeemer.tokenIndexes(address(aura));

        WarRedeemer.RedeemTicket[] memory userRedeemTickets = redeemer.getUserRedeemTickets(alice);
        uint256 newUserRedeemTicketsLength = redeemAmountCvx > 0 && redeemAmountAura > 0 ? 
            userRedeemTicketsLength + 2 
            : userRedeemTicketsLength + 1;
        
        assertEq(userRedeemTickets.length, newUserRedeemTicketsLength);

        if(redeemAmountCvx > 0) {
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

        if(redeemAmountAura > 0) {
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

    function testOnlyOneToken(uint256 amount) public {
        vm.assume(amount <= 1_000e18);
        vm.assume(amount > 1e9);

        address[] memory tokens = new address[](1);
        tokens[0] = address(cvx);
        uint256[] memory weights = new uint256[](1);
        weights[0] = 10_000;

        uint256 userRedeemTicketsLength = (redeemer.getUserRedeemTickets(alice)).length;

        (uint256 prevCvxQueueIndex,) = redeemer.tokenIndexes(address(cvx));

        uint256 expectedFeeAmount = (amount * redeemer.redeemFee()) / 10_000;

        uint256 burnAmountForCvx = ((amount - expectedFeeAmount) * 10_000) / 10_000;

        uint256 redeemAmountCvx = ratios.getBurnAmount(address(cvx), burnAmountForCvx);

        uint256 cvxTicketIndex = userRedeemTicketsLength;

        vm.startPrank(alice);

        vm.expectEmit(true, true, false, true);
        emit NewRedeemTicket(address(cvx), alice, cvxTicketIndex, redeemAmountCvx, prevCvxQueueIndex + redeemAmountCvx);

        redeemer.joinQueue(tokens, weights, amount);

        vm.stopPrank();

        (uint256 newCvxQueueIndex,) = redeemer.tokenIndexes(address(cvx));

        WarRedeemer.RedeemTicket[] memory userRedeemTickets = redeemer.getUserRedeemTickets(alice);
        
        assertEq(userRedeemTickets.length, userRedeemTicketsLength + 1);

        assertEq(newCvxQueueIndex, prevCvxQueueIndex + redeemAmountCvx);

        WarRedeemer.RedeemTicket memory newCvxTicket = userRedeemTickets[cvxTicketIndex];
        assertEq(newCvxTicket.id, cvxTicketIndex);
        assertEq(newCvxTicket.token, address(cvx));
        assertEq(newCvxTicket.amount, redeemAmountCvx);
        assertEq(newCvxTicket.redeemIndex, newCvxQueueIndex);
        assertEq(newCvxTicket.redeemed, false);
    }

    function testZeroAmount() public {
        address[] memory tokens = new address[](2);
        tokens[0] = address(cvx);
        tokens[1] = address(aura);
        uint256[] memory weights = new uint256[](2);
        weights[0] = 5000;
        weights[1] = 5000;

        vm.startPrank(alice);

        vm.expectRevert(Errors.ZeroValue.selector);
        redeemer.joinQueue(tokens, weights, 0);

        vm.stopPrank();
    }

    function testEmptyArray() public {
        address[] memory tokens = new address[](0);
        uint256[] memory weights = new uint256[](2);
        weights[0] = 5000;
        weights[1] = 5000;

        vm.startPrank(alice);

        vm.expectRevert(Errors.EmptyArray.selector);
        redeemer.joinQueue(tokens, weights, 100e18);

        vm.stopPrank();
    }

    function testArrayLengthMismatch() public {
        address[] memory tokens = new address[](2);
        tokens[0] = address(cvx);
        tokens[1] = address(aura);
        uint256[] memory weights = new uint256[](1);
        weights[0] = 5000;

        vm.startPrank(alice);

        vm.expectRevert(abi.encodeWithSelector(Errors.DifferentSizeArrays.selector, tokens.length, weights.length));
        redeemer.joinQueue(tokens, weights, 100e18);

        vm.stopPrank();
    }

    function testWeightOverflow(uint256 amount) public {
        vm.assume(amount <= 1_000e18);
        vm.assume(amount > 1e9);
        
        address[] memory tokens = new address[](2);
        tokens[0] = address(cvx);
        tokens[1] = address(aura);
        uint256[] memory weights = new uint256[](2);
        weights[0] = 6000;
        weights[1] = 5500;

        vm.startPrank(alice);

        vm.expectRevert(Errors.InvalidWeightSum.selector);
        redeemer.joinQueue(tokens, weights, amount);

        vm.stopPrank();
    }

    function testWeightsInvalid(uint256 amount) public {
        vm.assume(amount <= 1_000e18);
        vm.assume(amount > 1e9);
        
        address[] memory tokens = new address[](2);
        tokens[0] = address(cvx);
        tokens[1] = address(aura);
        uint256[] memory weights = new uint256[](2);
        weights[0] = 2000;
        weights[1] = 5500;

        vm.startPrank(alice);

        vm.expectRevert(Errors.InvalidWeightSum.selector);
        redeemer.joinQueue(tokens, weights, amount);

        vm.stopPrank();
    }

    function testWeightsInvalid2(uint256 amount) public {
        vm.assume(amount <= 1_000e18);
        vm.assume(amount > 1e9);
        
        address[] memory tokens = new address[](1);
        tokens[0] = address(cvx);
        uint256[] memory weights = new uint256[](1);
        weights[0] = 5500;

        vm.startPrank(alice);

        vm.expectRevert(Errors.InvalidWeightSum.selector);
        redeemer.joinQueue(tokens, weights, amount);

        vm.stopPrank();
    }

    function testTokenNotListed(address token) public {
        vm.assume(token != address(cvx) && token != address(aura));
        vm.assume(token != address(0));

        address[] memory tokens = new address[](2);
        tokens[0] = token;
        tokens[1] = address(aura);
        uint256[] memory weights = new uint256[](2);
        weights[0] = 5000;
        weights[1] = 5000;

        vm.startPrank(alice);

        vm.expectRevert(Errors.NotListedLocker.selector);
        redeemer.joinQueue(tokens, weights, 10e18);

        vm.stopPrank();
    }

    function testWhenNotPaused(uint256 amount) public {
        address[] memory tokens = new address[](2);
        tokens[0] = address(cvx);
        tokens[1] = address(aura);
        uint256[] memory weights = new uint256[](2);
        weights[0] = 5000;
        weights[1] = 5000;

        vm.prank(admin);
        redeemer.pause();

        vm.expectRevert("Pausable: paused");

        redeemer.joinQueue(tokens, weights, amount);
    }

}
