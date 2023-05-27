// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "./E2ETest.sol";

contract NormalUsage is E2ETest {
  function testScenario() public {

    deal(address(cvx), alice, 1e30);
    deal(address(aura), alice, 1e30);

    console.log("Alice has CVX: %e", cvx.balanceOf(alice));
    console.log("Alice has AURA: %e", aura.balanceOf(alice));

    address[] memory vlTokens = new address[](2);
    vlTokens[0] = address(cvx);
    vlTokens[1] = address(aura);
    uint256[] memory amounts = new uint256[](2);
    amounts[0] = 1e30;
    amounts[1] = 1e30;

    vm.startPrank(alice);
    cvx.approve(address(zap), type(uint256).max);
    aura.approve(address(zap), type(uint256).max);
    zap.zapMultiple(vlTokens, amounts, alice);

    (address[] memory otherStakers, ) = fuzzRewardsAndStakers(5678, 30);
    for (uint256 i; i < otherStakers.length; ++i) {
      // console.log("%e", staker.balanceOf(otherStakers[i]));
    }

    vm.prank(otherStakers[0]);
    staker.claimAllRewards(bob);
    console.log("other staker: %e", cvxCrv.balanceOf(bob));

    vm.startPrank(alice);

    console.log("Alice has stkWAR: %e", staker.balanceOf(alice));

    vm.warp(block.timestamp + 1);

    /*WarStaker.UserClaimedRewards[] memory rewards = */staker.claimAllRewards(alice);

    for (uint256 i; i < queueableRewards.length; ++i) {
      console.log("Alice claimed: %e %s", IERC20(queueableRewards[i]).balanceOf(alice), vm.getLabel(queueableRewards[i]));
    }
    console.log("Alice claimed: %e %s", IERC20(auraBal).balanceOf(alice), vm.getLabel(address(auraBal)));
    console.log("Alice claimed: %e %s", IERC20(cvxCrv).balanceOf(alice), vm.getLabel(address(cvxCrv)));

    address redeemerStaker = otherStakers[5];
    vm.startPrank(redeemerStaker);
    staker.unstake(staker.balanceOf(redeemerStaker), redeemerStaker);

    console.log("Alice unstaked: %e WAR", war.balanceOf(redeemerStaker));

    war.approve(address(redeemer), type(uint256).max);
    redeemer.joinQueue(war.balanceOf(redeemerStaker));
    WarRedeemer.RedeemTicket[] memory tickets = redeemer.getUserRedeemTickets(redeemerStaker);
    console.log("The stakerRedeemer got %d tickets", tickets.length);

    console.log("The stakerRedeemer has: %e WAR because they were put them in the queue", war.balanceOf(redeemerStaker));

    vm.warp(block.timestamp + 20 weeks);
    console.log("Making the time move...");

    uint256[] memory ids = new uint256[](tickets.length);
    for (uint256 i; i < tickets.length; ++i) {
      ids[i] = tickets[i].id;
    }
    redeemer.redeem(ids, redeemerStaker);
    
    console.log("The stakerRedeemer has CVX: %e", cvx.balanceOf(redeemerStaker));
    console.log("The stakerRedeemer has AURA: %e", aura.balanceOf(redeemerStaker));

    vm.stopPrank();
  }
}
