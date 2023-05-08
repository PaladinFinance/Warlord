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
    // TODO vm.expectCall when new version available
    // vm.expectCall(address(mock), abi.encodeCall(mock.balanceOf, address(controller)), 0);
    controller.process(zero);
  }

  function testZeroBalance() public {
    // TODO vm.expectCall when new version available
    IERC20 mock = IERC20(address(new MockERC20()));
    controller.process(address(mock));
  }

  function computeFee(uint256 balance) public view returns (uint256) {
    console.log((balance * controller.feeRatio()) / 10_000);
    return (balance * controller.feeRatio()) / 10_000;
  }

  function assertFee(address token, uint256 amount) public {
    uint256 fee = computeFee(amount);
    uint256 balance = IERC20(token).balanceOf(protocolFeeReceiver);
    assertGt(balance, 0, "The fee taken should always be non zero");
    assertEqDecimal(balance, fee, 18, "Fee is sent to the correct receiver");
  }

  // TODO test with initial amounts that are non zeor
  function testLocker(uint256 amount) public {
    vm.assume(amount > 1e5 && amount < 1e33);
    uint256 fee = computeFee(amount);

    address token = randomVlToken(amount);
    deal(token, address(controller), amount);

    uint256 initialQueuedWar = war.balanceOf(address(staker));

    controller.process(token);

    uint256 warDelta = war.balanceOf(address(staker)) - initialQueuedWar;
    assertEqDecimal(warDelta, amount - fee, 18, "Fee should have been taken from locked amount");
    assertFee(token, amount);
  }

  function testFarmer(uint256 amount) public {
    vm.assume(amount > 1e5 && amount < 1e50);

    uint256 fee = computeFee(amount);
    // console.log(vm.getLabel())

    address token = randomFarmableToken(amount);
    address farmer = controller.tokenFarmers(token);
    address staker = farmer == address(cvxCrvFarmer) ? address(convexCvxCrvStaker) : address(auraBalStaker);

    deal(token, address(controller), amount);

    uint256 initialStakedAmount = IERC20(token).balanceOf(staker);
    console.log("initial staked amount", initialStakedAmount);

    controller.process(token);

    uint256 stakeDelta = IERC20(token).balanceOf(staker) - initialStakedAmount;
    console.log("delta", initialStakedAmount);
    assertEqDecimal(stakeDelta, amount - fee, 18, "Fee should have been taken from staked amount");
    assertFee(token, amount);
  }

  function testDirectDistribution(/* uint256 amount */) public {
    // vm.assume(amount > 1e5 && amount < 1e50);
    uint256 amount = 5231075758742521659043321953617;

    uint256 fee = computeFee(amount);

    address token = queueableRewards[amount % queueableRewards.length];
    deal(token, address(controller), amount);

    uint256 initialQueuedReward = war.balanceOf(address(staker));

    controller.process(token);

    uint256 rewardDelta = war.balanceOf(address(staker)) - initialQueuedReward;
    assertEqDecimal(rewardDelta, amount - fee, 18, "Fee should have been taken from the rewards");
    assertFee(token, amount);
  }

  function testSwapToken(/*uint256 amount*/) public {
    uint256 amount = 403785;

    vm.assume(amount > 1e5);
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
