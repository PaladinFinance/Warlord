// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./ControllerTest.sol";

contract Process is UnexposedControllerTest {
  function testWhenNotPaused(address reward) public {
    vm.prank(admin);
    controller.pause();

    vm.expectRevert("Pausable: paused");
    controller.process(reward);
  }

  function testZeroAddress() public {
    IERC20 mock = IERC20(address(new MockERC20()));

    vm.expectCall(address(mock), abi.encodeCall(mock.balanceOf, address(controller)), 0);
    controller.process(zero);
  }

  function testZeroBalance() public {
    IERC20 mock = IERC20(address(new MockERC20()));
    vm.expectCall(address(mock), abi.encodeCall(mock.balanceOf, address(controller)), 1);
    vm.expectCall(address(mock), abi.encodeCall(mock.transfer, (protocolFeeReceiver, 0)), 0);
    controller.process(address(mock));
  }

  function assertFee(address token, uint256 amount) public {
    uint256 fee = computeFee(amount);
    uint256 balance = IERC20(token).balanceOf(protocolFeeReceiver);
    assertGt(balance, 0, "The fee taken should always be non zero");
    assertEqDecimal(balance, fee, 18, "Fee is sent to the correct receiver");
  }

  function testLocker(uint256 amount) public {
    vm.assume(amount > 1e5 && amount < 1e33);
    uint256 fee = computeFee(amount);

    address token = randomVlToken(amount);
    deal(token, address(controller), amount);

    uint256 initialQueuedWar = war.balanceOf(address(staker));

    controller.process(token);

    uint256 expectedMintedAmount = ratios.getMintAmount(token, amount - fee);

    uint256 warDelta = war.balanceOf(address(staker)) - initialQueuedWar;

    assertEqDecimal(warDelta, expectedMintedAmount, 18, "Fee should have been taken from locked amount");
    assertFee(token, amount);
  }

  function testLockerMultipleTimes(uint256 amount, uint256 previousAmount) public {
    vm.assume(amount > 1e5 && amount < 1e33);
    vm.assume(previousAmount > 1e5 && previousAmount < 1e33);

    address token = randomVlToken(amount);

    // previous process
    deal(token, address(controller), previousAmount);
    controller.process(token);

    vm.warp(block.timestamp + 604_800);

    // -----------

    uint256 fee = computeFee(amount);
    uint256 startFeeBalance = IERC20(token).balanceOf(protocolFeeReceiver);

    deal(token, address(controller), amount);

    uint256 initialQueuedWar = war.balanceOf(address(staker));

    controller.process(token);

    uint256 expectedMintedAmount = ratios.getMintAmount(token, amount - fee);

    uint256 warDelta = war.balanceOf(address(staker)) - initialQueuedWar;

    assertEqDecimal(warDelta, expectedMintedAmount, 18, "Fee should have been taken from locked amount");

    // can't use because does not consider previous process
    //assertFee(token, amount);

    uint256 feeBalanceDelta = IERC20(token).balanceOf(protocolFeeReceiver) - startFeeBalance;
    assertGt(feeBalanceDelta, 0, "The fee taken should always be non zero");
    assertEqDecimal(feeBalanceDelta, fee, 18, "Fee is sent to the correct receiver");
  }

  function testFarmer(uint256 amount) public {
    vm.assume(amount > 1e5 && amount < 1e50);

    uint256 fee = computeFee(amount);

    address token = randomFarmableToken(amount);
    address farmer = controller.tokenFarmers(token);
    // unwrapped staker
    address cvxCrvStaker = 0x3Fe65692bfCD0e6CF84cB1E7d24108E434A7587e;
    address staker = farmer == address(cvxCrvFarmer) ? address(cvxCrvStaker) : address(auraBalStaker);

    deal(token, address(controller), amount);

    uint256 initialStakedAmount = IERC20(token).balanceOf(staker);

    controller.process(token);

    uint256 stakeDelta = IERC20(token).balanceOf(staker) - initialStakedAmount;
    assertEqDecimal(stakeDelta, amount - fee, 18, "Fee should have been taken from staked amount");
    assertFee(token, amount);
  }

  function testDirectDistribution(uint256 amount) public {
    vm.assume(amount > 1e5 && amount < 1e50);

    uint256 fee = computeFee(amount);

    address token = queueableRewards[amount % queueableRewards.length];
    deal(token, address(controller), amount);

    uint256 initialQueuedReward = IERC20(token).balanceOf(address(staker));

    controller.process(token);

    uint256 rewardDelta = IERC20(token).balanceOf(address(staker)) - initialQueuedReward;
    assertEqDecimal(rewardDelta, amount - fee, 18, "Fee should have been taken from the rewards");
    assertFee(token, amount);
  }

  function testSwapToken(uint256 amount) public {
    vm.assume(amount > 1e5 && amount < 1e50);
    MockERC20 mock = new MockERC20();

    uint256 fee = computeFee(amount);

    deal(address(mock), address(controller), amount);

    uint256 initialSwapperAmount = controller.swapperAmounts(address(mock));

    controller.process(address(mock));

    uint256 swapperAmountDelta = controller.swapperAmounts(address(mock)) - initialSwapperAmount;
    assertEqDecimal(swapperAmountDelta, amount - fee, 18, "Fee should have taken from amount to dump");
    assertFee(address(mock), amount);
  }
}
