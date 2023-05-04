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
    return (balance * controller.feeRatio()) / 10_000;
  }

  function testLocker(uint256 amount) public {
    vm.assume(amount < 1e33);
    uint256 fee = computeFee(amount);

    address token = randomVlToken(amount);
    deal(token, address(controller), amount);

    uint256 initialQueuedWar = war.balanceOf(address(staker));

    controller.process(token);

    uint256 warDelta = war.balanceOf(address(staker)) - initialQueuedWar;
    assertEqDecimal(warDelta, amount - fee, 18, "Fee should have taken from queued amount");
  }

  function testFarmer(/* uint256 amount */) public {
    uint256 amount = 4984;
    uint256 fee = computeFee(amount);

    address token = randomFarmableToken(amount);
    address farmer = controller.tokenFarmers(token);
    console.log(farmer);

    deal(token, address(controller), amount);

    uint256 initialStakedAmount = IERC20(token).balanceOf(farmer);

    controller.process(token);

    uint256 stakeDelta = IERC20(token).balanceOf(farmer) - initialStakedAmount;
    console.log(stakeDelta);
    // assertEqDecimal(stakeDelta, amount - fee, 18, "Fee should have taken from queued amount");
  }
  function testDirectDistribution() public {
  }
  function testSwapToken() public {
  }
}
