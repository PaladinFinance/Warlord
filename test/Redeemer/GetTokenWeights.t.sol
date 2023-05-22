pragma solidity 0.8.16;
//SPDX-License-Identifier: MIT

import "./RedeemerTest.sol";

contract JoinQueue is RedeemerTest {
  // Because after joining the queue, the weights might change slightly (1 wei diff)
  uint256 constant ACCEPTED_PRECISION_LOSS = 10;

  function _getTokenIndexes(WarRedeemer.TokenWeight[] memory tokenWeights) internal pure returns (uint256, uint256) {
    bool isCvxFirst = tokenWeights[0].token == address(cvx);
    uint256 cvxIndex = isCvxFirst ? 0 : 1;
    uint256 auraIndex = isCvxFirst ? 1 : 0;

    return (cvxIndex, auraIndex);
  }

  function testDefaultBehavior() public {
    WarRedeemer.TokenWeight[] memory tokenWeights = redeemer.getTokenWeights();
    (uint256 cvxIndex, uint256 auraIndex) = _getTokenIndexes(tokenWeights);

    uint256 totalWarSupply = war.totalSupply();

    uint256 cvxLockerCurrentBalance = cvxLocker.getCurrentLockedTokens() - redeemer.queuedForWithdrawal(address(cvx));
    uint256 auraLockerCurrentBalance = auraLocker.getCurrentLockedTokens() - redeemer.queuedForWithdrawal(address(aura));

    uint256 cvxRatio = ratios.getTokenRatio(address(cvx));
    uint256 auraRatio = ratios.getTokenRatio(address(aura));

    uint256 cvxWeight = ((cvxLockerCurrentBalance * cvxRatio)) / totalWarSupply;
    uint256 auraWeight = ((auraLockerCurrentBalance * auraRatio)) / totalWarSupply;

    assertEq(tokenWeights[cvxIndex].weight, cvxWeight);
    assertEq(tokenWeights[auraIndex].weight, auraWeight);
  }

  function _extraDepostits(uint256 extraCvxDeposit, uint256 extraAuraDeposit) internal {
    address[] memory lockers;
    uint256[] memory amounts;

    if (extraCvxDeposit > 0 && extraAuraDeposit > 0) {
      lockers = new address[](2);
      lockers[0] = address(cvx);
      lockers[1] = address(aura);
      amounts = new uint256[](2);
      amounts[0] = extraCvxDeposit;
      amounts[1] = extraAuraDeposit;
    } else if (extraCvxDeposit > 0) {
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

  function testExtraDeposits(uint256 extraCvxDeposit, uint256 extraAuraDeposit) public {
    vm.assume(extraCvxDeposit <= 5000e18);
    vm.assume(extraAuraDeposit <= 5000e18);
    vm.assume(extraCvxDeposit > 0 && extraAuraDeposit > 0);

    WarRedeemer.TokenWeight[] memory tokenWeights = redeemer.getTokenWeights();
    (uint256 cvxIndex, uint256 auraIndex) = _getTokenIndexes(tokenWeights);

    uint256 totalWarSupply = war.totalSupply();

    uint256 cvxLockerCurrentBalance = cvxLocker.getCurrentLockedTokens() - redeemer.queuedForWithdrawal(address(cvx));
    uint256 auraLockerCurrentBalance = auraLocker.getCurrentLockedTokens() - redeemer.queuedForWithdrawal(address(aura));

    uint256 cvxRatio = ratios.getTokenRatio(address(cvx));
    uint256 auraRatio = ratios.getTokenRatio(address(aura));

    uint256 cvxWeight = ((cvxLockerCurrentBalance * cvxRatio)) / totalWarSupply;
    uint256 auraWeight = ((auraLockerCurrentBalance * auraRatio)) / totalWarSupply;

    assertEq(tokenWeights[cvxIndex].weight, cvxWeight);
    assertEq(tokenWeights[auraIndex].weight, auraWeight);
  }

  function testAfterJoinQueue(uint256 amount) public {
    vm.assume(amount <= 1000e18);
    vm.assume(amount > 1e9);

    WarRedeemer.TokenWeight[] memory prevTokenWeights = redeemer.getTokenWeights();

    vm.startPrank(alice);
    war.approve(address(redeemer), type(uint256).max);
    redeemer.joinQueue(amount);
    vm.stopPrank();

    WarRedeemer.TokenWeight[] memory newTokenWeights = redeemer.getTokenWeights();

    assertEq(
      newTokenWeights[0].weight / ACCEPTED_PRECISION_LOSS * ACCEPTED_PRECISION_LOSS,
      prevTokenWeights[0].weight / ACCEPTED_PRECISION_LOSS * ACCEPTED_PRECISION_LOSS
    );
    assertEq(
      newTokenWeights[1].weight / ACCEPTED_PRECISION_LOSS * ACCEPTED_PRECISION_LOSS,
      prevTokenWeights[1].weight / ACCEPTED_PRECISION_LOSS * ACCEPTED_PRECISION_LOSS
    );
  }
}
